require 'lims-warehousebuilder/core_ext'

module Lims::WarehouseBuilder
  module Model
    class SampleManagementActivity < Sequel::Model(:historic_sample_management_activity)

      include ResourceTools::Mapping
      include Common

      # @param [String] uuid
      # @return [Array<Models::SampleManagementActivity>]
      # An item is involved in x activities, x being the number
      # of samples contained in the resource referenced in the item.
      def self.last_activities_by_order_item_uuid(uuid)
        sample_uuids = SampleContainerHelper.sample_uuids_by_container_uuid(uuid)
        self.dataset.from(current_table_name).where(:uuid => sample_uuids).all
      end

      # @param [String] sample_uuid
      # @return [Bool] true if a row exists in the sample_management_activity 
      # tables for the given sample uuid.
      # We look for the sample_uuid in the current table instead of the 
      # historic one for performance issue as it's smaller.
      def self.activity_for_sample?(sample_uuid)
        self.dataset.from(current_table_name).where(:uuid => sample_uuid).count > 0
      end

      def dispatch_attributes(item_uuid, role, status, at, by)
        at = at.to_s unless at.is_a? String
        role = format_role(role)
        if is_older?(role, status, at)
          set_role_uuid(item_uuid, role)
          set_role_status_at(role, status, at)
          set_role_status_by(role, status, by)
        end
        self
      end

      private

      # @param [String] role
      # @return [String]
      # Replace the dot in the role with an underscore.
      # Remove samples.extraction. due to mysql limitation
      # on column name size.
      def format_role(role)
        role.gsub(/\./, '_').contract
      end

      # @param [String] role
      # @param [String] status
      # @param [String] at
      # @return [Bool]
      # Return true if the new "at" attribute is older
      # than what is saved in the database for the role/status
      # in parameter. The to_be_saved variable determines if
      # we want to save or not the instance of sample_management_activity.
      def is_older?(role, status, at)
        column = "#{role}_#{status}_at".to_sym
        begin
          saved_at = self.send(column)
        rescue
          raise ProcessingFailed, "Unknown column name '#{column}' in the sample management activity table. Cannot handle role '#{role}'"
        end
        new_at = DateTime.parse(at).to_time.utc
        saved_at ? new_at < saved_at : true
      end

      def set_role_uuid(uuid, role)
        column = "#{role}_uuid".to_sym
        self.send("#{column}=", uuid)
      end

      def set_role_status_at(role, status, at)
        column = "#{role}_#{status}_at".to_sym
        self.send("#{column}=", at)
      end

      def set_role_status_by(role, status, by)
        column = "#{role}_#{status}_by".to_sym
        self.send("#{column}=", by)
      end
    end
  end
end

