require 'lims-warehousebuilder/json_decoder'

module Lims::WarehouseBuilder
  module Decoder
    class OrderDecoder < JsonDecoder

      private

      def _call(options)
        order = super
        [order, items, sample_management_activity]
      end

      # @return [Array<Model::Item>]
      def items
      # TODO: items doesn't have uuid, the uuid is the one of the resource
      # The nuple (uuid, order_id, role) is unique, uuid alone is not ie a same resource
      # can appear under different role in a same order.
      #  items = []
      #  @payload["items"].each do |role, items_array|
      #    items_array.each do |item|
      #      model = prepared_model(item["uuid"], "item")
      #      # to set the created_at and created_by from @payload
      #      payload = self.class.complete_value(item.merge({"role" => role}), @payload, {})
      #      items << map_attributes_to_model(model, payload)
      #    end
      #  end
      #  items
        nil
      end

      # @return [Array<Model::SampleManagementActivity>]
      def sample_management_activity
        klass = model_for("sample_management_activity")
        at = @payload["date"]
        by = @payload["user"]
        activities = {}

        @payload["items"].each do |role, items_array|
          items_array.each do |item|
            uuid = item["uuid"]
            status = item["status"]

            begin
              # An item is involved in x activies, x being the number
              # of samples it contains.
              klass.last_activities_by_order_item_uuid(uuid).each do |activity|
                # A same activity can be referenced by different items.
                # Ex: two resources contain the same sample
                # We use the same activity for both cases.
                new_activity = activities.fetch(activity.uuid) do |key|
                  activities[key] = clone_model_object(activity)
                end

                # We set the new data for the activity and push it in 
                # memory.
                new_activity.dispatch_attributes(uuid, role, status, at, by)
                activities[activity.uuid] = new_activity
              end
            rescue Model::NotFound
              raise MessageToBeRequeued
            end
          end
        end

        activities.values
      end
    end
  end
end
