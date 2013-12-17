require 'lims-warehousebuilder/base_trigger'

module Lims::WarehouseBuilder
  module Trigger
    class AliquotTrigger < BaseTrigger

      def after_trigger_sql
        %Q{
        BEGIN
        DELETE FROM #{@current_table} WHERE container_uuid = NEW.container_uuid AND position = NEW.position AND sample_uuid = NEW.sample_uuid;
        DELETE FROM #{@current_table} WHERE internal_id = NEW.internal_id;
        INSERT INTO #{@current_table}(#{@columns.join(',')}) VALUES(#{new_values});
        END
        }
      end
      private :after_trigger_sql

    end
  end
end
