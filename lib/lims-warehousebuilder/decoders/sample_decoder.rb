require 'lims-warehousebuilder/json_decoder'

module Lims::WarehouseBuilder
  module Decoder
    class SampleDecoder < JsonDecoder

      private

      # The SampleDecoder returns both Sample model
      # and SampleManagementActivity model.
      def _call(options)
        [].tap do |objects|
          if @payload["ancestor_uuid"]
            # Sample which are part from other laboratory asset like tubes...
            objects << sample_container_association
          else
            # Sample object from lims-management-app. Are not part
            # of other s2 resource so they don't have an ancestor_uuid.
            if options[:action] =~ /delete/
              objects << prepared_model(@payload["uuid"], @model).tap do |sample|
                sample.deleted_at = @payload["date"]
                sample.deleted_by = @payload["user"]
              end
            else
              objects << super unless @payload["ancestor_uuid"]
            end
          end
        end
      end

      # @return [Sequel::Model]
      def sample_container_association
        Model::SampleContainerHelper.new({
          :sample_uuid => @payload["uuid"],
          :container_uuid => @payload["ancestor_uuid"],
          :container_model => @payload["ancestor_type"]
        })
      end
    end
  end
end

