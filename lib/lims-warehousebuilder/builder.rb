require 'lims-busclient'
require 'lims-warehousebuilder/json_decoder'
require 'lims-warehousebuilder/base_trigger'
require 'set'

module Lims
  module WarehouseBuilder

    MessageToBeRequeued = Class.new(StandardError)
    ProcessingFailed = Class.new(StandardError)

    class Builder
      include Lims::BusClient::Consumer

      attribute :queue_name, String, :required => true, :writer => :private
      attribute :log, Object, :required => false, :writer => :private
      
      # @param [Hash] amqp_settings
      def initialize(amqp_settings)
        @queue_name = amqp_settings.delete("queue_name")
        consumer_setup(amqp_settings)
        set_queue
      end

      # @param [Logger] logger
      def set_logger(logger)
        @log = logger
      end

      private

      # Setup the queue
      # For each message we received, we process all the 
      # s2 resource it contains in the foreach_s2_resource loop.
      # For each s2 resource, we get the right decoder. Decoding
      # the resource gives back an instance of a Sequel model, ready 
      # to be saved in the warehouse.
      def set_queue
        self.add_queue(queue_name) do |metadata, json_payload|
          log.info("Message received with the routing key: #{metadata.routing_key}")
          log.debug("Processing message with routing key: '#{metadata.routing_key}' and payload: #{json_payload}")
          begin
            payload = JSON.parse(json_payload)
            action = metadata.routing_key.match(/^[\w\.]*\.(\w*)$/)[1]
            objects = decode_payload(payload, action)
            maintain_warehouse(objects)
            save_all(objects)
            metadata.ack
            log.info("Message processed and acknowledged")
          rescue Sequel::Rollback, MessageToBeRequeued => e
            metadata.reject(:requeue => true)
            log.info("Message requeued: #{e}")
          rescue ProcessingFailed => ex
            # TODO: use the dead lettering queue
            metadata.reject
            log.error("Processing the message '#{metadata.routing_key}' failed with: #{ex.to_s}")
          end
        end
      end

      # @param [Hash] payload
      # @param [String] action
      # @return [Array<Sequel::Model>]
      def decode_payload(payload, action)
        [].tap do |objects_to_save|
          Decoder::JsonDecoder.foreach_s2_resource(payload) do |model, attributes|
            decoder = decoder_for(model).new(model, attributes)
            objects = decoder.call({:action => action})
            objects_to_save << objects
          end
        end.flatten
      end

      # @param [String] name
      # @return [JsonDecoder]
      def decoder_for(name)
        Decoder::JsonDecoder.decoder_for(name)
      end

      # @param [Array] objects
      def save_all(objects)
        DB.transaction(:rollback => :reraise) do
          objects.each do |o|
            begin
              next unless o
              o.save
            rescue Sequel::HookFailed => e
              # if the model's before_save method fails
              log.error("Exception raised: #{e}")
            end
          end
        end
      end

      # @param [Array<Sequel::Model>] objects
      # Setup the triggers in the warehouse for each model involved
      # We first look for the model classes without duplicate so we
      # don't setup the same trigger twice.
      # The triggers are setup only for model associated with a
      # historic/current table.
      def maintain_warehouse(objects)
        Set.new.tap do |models|
          objects.each do |o| 
            klass = o.class
            next unless ResourceTools::Database::HISTORIC_TABLES.include?(klass.table_name.to_s)
            models << klass 
          end
        end.each do |model|
          Trigger.trigger_for(model).setup
        end
      end
    end
  end
end
