require 'lims-busclient'
require 'lims-warehousebuilder/json_decoder'
require 'lims-warehousebuilder/table_migration'

module Lims
  module WarehouseBuilder

    class MessageToBeRequeued < StandardError
    end

    class Builder
      include Lims::BusClient::Consumer
      include TableMigration

      attribute :queue_name, String, :required => true, :writer => :private
      attribute :log, Object, :required => false, :writer => :private
      
      EXPECTED_ROUTING_KEYS_PATTERNS = [
        '*.*.order.*',
        '*.*.tube.*',
        '*.*.spincolumn.*',
        '*.*.tuberack.*',
        '*.*.transfertubestotubes.*',
        '*.*.sample.*', '*.*.bulkcreatesample.*', 
        '*.*.bulkupdatesample.*', '*.*.bulkdeletesample.*' 
      ].map { |k| Regexp.new(k.gsub(/\./, "\\.").gsub(/\*/, ".*")) }

      # @param [Hash] amqp_settings
      # @param [Hash] warehouse_settings
      def initialize(amqp_settings, warehouse_settings)
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
        self.add_queue(queue_name) do |metadata, payload|
          log.info("Message received with the routing key: #{metadata.routing_key}")
          if expected_message?(metadata.routing_key)
            log.debug("Processing message with routing key: '#{metadata.routing_key}' and payload: #{payload}")
            begin
              action = metadata.routing_key.match(/^[\w\.]*\.(\w*)$/)[1]
              objects = decode_payload(payload, action)
              save(objects)
              metadata.ack
              log.info("Message processed and acknowledged")
            rescue MessageToBeRequeued
              metadata.reject(:requeue => true)
              log.info("Message requeued")
            rescue Model::ProcessingFailed => ex
              # TODO: use the dead lettering queue
              metadata.reject
              log.error("Processing the message '#{metadata.routing_key}' failed with: #{ex.to_s}")
            end
          else
            metadata.reject
            log.error("Message rejected: cannot handle this message (routing key: #{metadata.routing_key})")
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

      # @param [String] routing_key
      # @return [Bool]
      def expected_message?(routing_key)
        EXPECTED_ROUTING_KEYS_PATTERNS.each do |pattern|
          return true if routing_key.match(pattern)
        end
        false
      end

      # @param [String] name
      # @return [JsonDecoder]
      def decoder_for(name)
        Decoder::JsonDecoder.decoder_for(name)
      end

      # @param [Array] objects
      def save(objects)
        objects.each do |o|
          begin
            o.save if o
          rescue Sequel::HookFailed => e
            # if the model's before_save method fails
            log.error("Exception raised: #{e}")
          end
        end
      end
    end
  end
end
