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
        @date = payload["date"]
        @user = payload["user"]
        @uuid = payload["uuid"]
      end

      # @param [Hash] options
      # @return [Array<Sequel::Model>]
      def call(options = {})
        result = _call(options)
        result.is_a?(Array) ? result.flatten.compact : [result]
      end

      # @param [Hash,String] payload
      # @param [Hash] payload_ancestor
      # @param [String,Nil] model
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
      def self.foreach_s2_resource(payload, payload_ancestor = {}, model=nil, &block) 
        payload.each do |key, value|
          next unless value.is_a?(Hash) || value.is_a?(Array) # Prevent useless loop
          singular_key = s2_resource_singular(key)
          local_payload_ancestor = payload_ancestor.clone

          # Handle usual s2_resource: :tube => {tube payload}
          # and nested s2 resource with indirect key: :tubes => {"A1" => {tube payload}, "A2" => ...}
          # model passed in parameter of the method is used only when the key is a location.
          model = case 
                  when is_s2_resource_name?(key) then key
                  when is_s2_resource_name?(singular_key) then singular_key
                  when is_a_location_key?(key) then model
                  else nil
                  end

          if is_s2_resource?(model, value)
            location = is_a_location_key?(key) ? key : nil
            value = complete_value(value, payload, payload_ancestor.merge(:location => location))
            local_payload_ancestor = {:ancestor_type => model, :ancestor_uuid => payload[key]["uuid"]}
            block.call(model, value)
           
          elsif is_s2_resources_array?(key, value)
            # Handle the case we have an array of resources like :samples => [{sample1}, {sample2},...]
            # The following add the type in front of each resource in the array. For example: 
            # :samples => [{:sample => {sample1}}, {:sample => {sample2}}, ...]
            value = value.map { |v| {singular_key => v} } 

          elsif is_a_decoder?(key)
            # Handle custom decoders like for swap sample. No resource corresponds to <key>, 
            # we just call the decoder and stop the loop after. It is used only for specific
            # payload like swap samples for which we need the full message payload to be
            # able to update correctly the warehouse.
            value = complete_value(value, payload, payload_ancestor)
            block.call(key, value)
            break
          end

          case value
          when Hash then 
            value = complete_value(value, payload, local_payload_ancestor)
            foreach_s2_resource(value, local_payload_ancestor, model, &block)
          when Array then 
            value.each do |e|
              if e.is_a?(Hash)
                e = complete_value(e, payload, local_payload_ancestor)
                foreach_s2_resource(e, local_payload_ancestor, model, &block)
              end
            end
          end
        end
      end

      # @param [String] name
      # @return [JsonDecoder]
      # NameToDecoder keys do not include any special characters.
      def self.decoder_for(name)
        name_alphanum = name.gsub(/[^0-9a-zA-Z]/, '')
        NameToDecoder[name_alphanum] ? NameToDecoder[name_alphanum] : NameToDecoder["json"]
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
          payload_ancestor.each do |attribute, data|
            v[attribute.to_s] = data
          end

          SHARED_ATTRIBUTES.each do |attr|
            v[attr] = payload[attr]
          end
        end
      end

      # @param [String] name
      # @return [Bool]
      # A union between S2_MODELS and NameToDecoder is needed here
      # for the case a s2 resource doesn't have direct corresponding
      # model in the warehouse. For example: labellable.
      def self.is_s2_resource_name?(name)
        (ResourceTools::Database::S2_MODELS | NameToDecoder.keys - ["json"]).include?(name)
      end

      # @param [String] name
      # @return [Bool]
      # Return true if 'name' is a location like "A1", "E10"...
      def self.is_a_location_key?(name)
        name =~ /^[a-zA-Z][0-9]+$/
      end

      # @param [String] name
      # @param [Hash] content
      # @return [Bool]
      # Return true if the name is a s2 resource name and if the resource has an uuid.
      # The uuid criteria is used to discard the content which have a s2 name
      # but are not a resource (like in bulk_create_tube, the action parameters are 
      # listed under "tubes").
      def self.is_s2_resource?(name, content)
        is_s2_resource_name?(name) && content.is_a?(Hash) && content.has_key?("uuid")
      end

      # @param [String] name
      # @return [Bool]
      def self.is_a_decoder?(name)
        name_alphanum = name.gsub(/[^0-9a-zA-Z]/, '')
        (NameToDecoder.keys - ["json"]).include?(name_alphanum)
      end

      # @param [String] name
      # @return [Bool]
      def self.is_s2_resources_array?(name, value)
        singular_name = s2_resource_singular(name)
        singular_name ? is_s2_resource_name?(singular_name) && value.is_a?(Array) : false 
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

      # Sometimes only the updated_at/by is needed to be
      # updated but no other attributes are changed.
      # In that case, we can pass the to_be_saved? validation
      # settings the force_save parameter to true.
      # For example, when we update a tube rack just adding a new
      # tube, none of the tube rack parameters are changed, but we
      # need to update the date.
      def force_save!
        @force_save = true
      end

      # The force save parameter is used only one time. It is 
      # resetted to false after it has been consumed by
      # to_be_saved? validation.
      def reset_force_save
        @force_save = false
      end

      # @param [Sequel::Model] model
      # @param [Hash] payload
      # For each attribute of the model, we check if there is a new
      # value in the payload to update it. If nothing is new, we don't
      # need to continue to deal with that model.
      def to_be_saved?(model, payload)
        if @force_save
          reset_force_save
          return true
        end

        # Case a requeued messages arrived, its date is older than
        # the last info we have, then we don't store it.
        message_date = DateTime.parse(payload["date"]).to_time.utc
        return false if model.respond_to?(:updated_at) && model.updated_at && message_date < model.updated_at 

        attributes = model.columns - model.class.ignoreable - [model.primary_key]
        attributes.each do |attribute|
          model_value = model.send(attribute)
          payload_key = model.class.translations.inverse[attribute] || attribute.to_s 
          # There is at least one new attribute which needs to be saved
          return true if model_value != seek(payload, payload_key)
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
          value = case payload_key
                  when Array then payload_key.inject("") { |m,k| k.is_a?(Symbol) ? m << seek(payload, k) : m << k}
                  else seek(payload, payload_key) 
                  end

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
