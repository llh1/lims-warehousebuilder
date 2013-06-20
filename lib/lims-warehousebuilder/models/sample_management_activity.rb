require 'lims-warehousebuilder/core_ext'
require 'digest'

module Lims::WarehouseBuilder
  module Model
    class SampleManagementActivity < Sequel::Model(:sample_management_activity)

      def before_save
        set_order_id!
        set_hashed_index!
        return false if has_duplicate?
        set_is_current!
      end

      # @param [String] sample_uuid
      def set_sample_id!(sample_uuid)
        sample = Model.model_for_uuid(sample_uuid, "sample")
        self.sample_id = sample.internal_id
      end

      # @param [String] order_uuid
      # Order and Activity come from a same message. So the first
      # time an order message is received, we decode the order
      # and the corresponding activities, BUT the order is not yet
      # stored in the database. That's why the order_id is set 
      # in the before_save filter, once the order is previously 
      # saved (as it's returned in first position by OrderDecoder#_call).
      def set_order_uuid(order_uuid)
        @order_uuid = order_uuid
      end

      # @param [String] container_uuid
      # @param [String] modelname
      def set_sample_container_id!(container_uuid, modelname)
        container = Model.model_for_uuid(container_uuid, modelname)
        container_field = "#{modelname}_id="
        if self.respond_to?(container_field)
          self.send("#{modelname}_id=", container.internal_id)
        else
          raise DBSchemaError, "#{container_field} column cannot be found in sample_management_activity table"
        end
      end

      private
  
      # If a more recent activity than self is found
      # we do not change anything and set is_current to 0.
      # Otherwise, it means self is the most recent activity,
      # we update is_current flag of similar activities and
      # set self.is_current to 1.
      def set_is_current!
        most_recent_id = most_recent_activity
        unless most_recent_id
          update_is_current_flag
          self.is_current = 1
        else
          self.is_current = 0
        end
      end

      def set_order_id!
        order = Model.model_for_uuid(@order_uuid, "order")
        self.order_id = order.internal_id
      end

      # @return [Bool]
      # Return the internal id if a more recent
      # activity than self is found.
      def most_recent_activity
        result = self.class.dataset.where({
          :sample_id => sample_id,
          :order_id => order_id,
          :is_current => 1
        }).where('date > ?', date).first
        result ? result[:internal_id] : nil
      end

      # Set is_current to 0 for all the rows 
      # which mention <sample_id> and <order_id>
      def update_is_current_flag
        self.class.dataset.where({
          :sample_id => sample_id,
          :order_id => order_id,
          :is_current => 1
        }).update(:is_current => 0)
      end

      # Compute a unique representation of the activity and store
      # it in hashed_index. The hash is computed from sample_id, order_id,
      # process, step, status, resource_id (either tube_id or spin_column_id)
      # and the resource_type (either tube or spin_column)
      # TODO: make resource_id and resource_type generic. What if a new labware column is added?
      # need to update this method...
      # Also, if another activity instance has the same hashed_index, we can assume
      # it represents the same activity.
      def set_hashed_index!
        resource_id = tube_id ? tube_id : spin_column_id
        resource_type = tube_id ? "tube" : "spin_column"
        value = [sample_id, order_id, process, step, status, resource_id, resource_type].join
        self.hashed_index = Digest::MD5.hexdigest(value)        
      end

      # @return [Bool]
      # Return true if the current model is already 
      # stored in the database. 
      # Hashed_index column is indexed.
      def has_duplicate?
        self.class.dataset.where(:hashed_index => self.hashed_index).count > 0
      end
    end
  end
end

