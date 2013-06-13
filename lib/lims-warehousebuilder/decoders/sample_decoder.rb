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
            objects << sample_management_activity
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
          :container_uuid => @payload["ancestor_uuid"]
        })
      end

      # @return [Sequel::Model]
      # Initialize the row in the table sample_management_activity
      # for the sample, if it doesn't exist yet.
      def sample_management_activity
        sample_uuid = @payload["uuid"]
        klass = model_for("sample_management_activity")
        klass.activity_for_sample?(sample_uuid) ? nil : klass.new(:uuid => sample_uuid)
      end
    end
  end
end

