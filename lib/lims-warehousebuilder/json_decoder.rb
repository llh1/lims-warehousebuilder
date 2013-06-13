require 'json'
require 'facets/kernel'
require 'lims-warehousebuilder/model'
require 'lims-warehousebuilder/resource_tools'

module Lims::WarehouseBuilder
  module Decoder
    class JsonDecoder

      include Model
      include ResourceTools::Database
      include ResourceTools::NestedHash

      SHARED_ATTRIBUTES = %w{date user action}

      # @param [String] model
      # @param [Hash,String] payload
      def initialize(model, payload)
        @model = model 
        @payload = payload
      end

      # @param [Hash] options
      # @return [Array<Sequel::Model>]
      def call(options = {})
        result = _call(options)
        result.is_a?(Array) ? result.flatten.compact : [result]
      end

      # @param [Hash,String] payload
      # @param [Hash] payload_ancestor
      # @param [Block] block
      # Iterate over the payload and call the block for each
      # s2 resource found.
      # If a s2 resource is found in the payload, we add some 
      # information (useful if we handle a s2 nested resource 
      # in the payload) like the user, the date and the parent
      # resource in case of nested resource.
      # @example
      # If we find a sample, we add to its payload the resource
      # which includes the sample, for example a tube and its uuid.
      def self.foreach_s2_resource(payload, payload_ancestor = {}, &block) 
        payload = payload.is_a?(Hash) ? payload : self.to_hash(payload)

        payload.each do |key, value|
          if is_s2_resource?(key)
            value = complete_value(value, payload, payload_ancestor)
            payload_ancestor = {:model => key, :uuid => payload[key]["uuid"]}
            block.call(key, value)
          elsif is_s2_resources_array?(key, value)
            # Handle the case we have an array of resources like
            # :samples => [{sample1}, {sample2},...]
            # The following add the type in front of each resource
            # in the array. For example: 
            # :samples => [{:sample => {sample1}, {:sample => {sample2}}, ...]
            value = value.map { |v| {s2_resource_singular(key) => v} } 
          end

          case value
          when Hash then 
            value = complete_value(value, payload, payload_ancestor)
            foreach_s2_resource(value, payload_ancestor, &block)
          when Array then 
            value.each do |e|
              if e.is_a?(Hash)
                e = complete_value(e, payload, payload_ancestor)
                foreach_s2_resource(e, payload_ancestor, &block)
              end
            end
          end
        end
      end

      # @param [String] name
      # @return [JsonDecoder]
      def self.decoder_for(name)
        NameToDecoder[name] ? NameToDecoder[name] : NameToDecoder["json"]
      end

      # @param [String] json
      # @return [Hash]
      def self.to_hash(json)
        JSON.parse(json)
      end

      protected

      # @param [Hash] value
      # @param [Hash] payload
      # @param [Hash] payload_ancestor
      # @return [Hash]
      # Complete the partial payload with user, date and action
      # and informations about the parent resource in case 
      # of nested resource.
      def self.complete_value(value, payload, payload_ancestor)
        value.tap do |v|
          v["ancestor_type"] = payload_ancestor[:model] if payload_ancestor[:model]
          v["ancestor_uuid"] = payload_ancestor[:uuid] if payload_ancestor[:uuid]
          SHARED_ATTRIBUTES.each do |attr|
            v[attr] = payload[attr]
          end
        end
      end

      # @param [String] name
      # @return [Bool]
      def self.is_s2_resource?(name)
        ResourceTools::Database::S2_MODELS.include?(name)
      end

      # @param [String] name
      # @return [Bool]
      def self.is_s2_resources_array?(name, value)
        singular_name = s2_resource_singular(name)
        singular_name ? is_s2_resource?(singular_name) && value.is_a?(Array) : false 
      end

      # @param [String] name
      # @return [String]
      def self.s2_resource_singular(name)
        name.match(/^(\w*)s$/) ? $1 : nil
      end

      # @param [Hash] options
      # @return [Array<Sequel::Model>]
      def _call(options)
        [map_attributes_to_model(prepared_model(@payload["uuid"], @model))]
      end

      # @param [Sequel::Model] model
      # @param [Hash] payload
      # For each attribute of the model, we check if there is a new
      # value in the payload to update it. If nothing is new, we don't
      # need to continue to deal with that model.
      def to_be_saved?(model, payload)
        # Case a requeued messages arrived, its date is older than
        # the last info we have, then we don't store it.
        message_date = DateTime.parse(payload["date"]).to_time.utc
        return false if model.updated_at && message_date < model.updated_at 

        attributes = model.columns - model.class.ignoreable - [model.primary_key]
        attributes.each do |attribute|
          payload_key = model.class.translations.inverse[attribute] || attribute.to_s 
          # There is at least one new attribute which needs to be saved
          return true if attribute != seek(payload, payload_key)
        end
        false
      end

      # @param [Sequel::Model] model
      # @param [Hash] payload
      # @return [Sequel::Model]
      # Map the data of the payload to the attributes of the model.
      # The name of the data in the payload and the name of the
      # attributes in the model could be different. So, a translation
      # map is defined in the models which need to.
      def map_attributes_to_model(model, payload = @payload)
        # TODO: what if message1.date >  message2.date and model1 == model2
        # ie message 2 is the earliest message but arrived late in the queue
        return nil unless to_be_saved?(model, payload)

        (model.columns - [model.primary_key]).each do |attribute|
          payload_key = model.class.translations.inverse[attribute] || attribute.to_s 
          value = seek(payload, payload_key)
          model.send("#{attribute}=", value) unless value.nil? # use nil? otherwise side effect with boolean values
        end
        model
      end
    end
  end
end

require_all('decoders/*.rb')

module Lims::WarehouseBuilder
  NameToDecoder = {}.tap do |h|
    Lims::WarehouseBuilder::Decoder::constants.each do |name|
      c = Lims::WarehouseBuilder::Decoder.const_get(name)
      h[name.to_s.downcase.sub(/decoder/, '')] = c if c.ancestors.include?(Lims::WarehouseBuilder::Decoder::JsonDecoder)
    end
  end
end
