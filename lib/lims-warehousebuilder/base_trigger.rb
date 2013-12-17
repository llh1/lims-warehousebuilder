require 'facets/kernel'

module Lims::WarehouseBuilder
  module Trigger
    class BaseTrigger

      # @param [Class] model_class
      def initialize(model_class)
        @historic_table = model_class.table_name
        @current_table = model_class.current_table_name
        @columns = model_class.columns
      end

      # Delete the trigger and recreate it
      def setup
        drop_trigger(trigger_name)
        after_trigger(after_trigger_sql, {
          :name => trigger_name,
          :event => :insert,
          :on => @historic_table
        })
      end

      private

      # @return [String]
      def trigger_name
        "maintain_#{@current_table}_trigger"
      end

      # @return [String]
      def new_values
        @columns.map { |c| "NEW.#{c}" }.join(',')
      end

      # @return [String]
      # As internal_id is unique, we delete first the NEW.internal_id 
      # which comes from the historic table from the current table.
      # It shouldn't happen normally as all the rows in the current 
      # table come from the historic table.
      def after_trigger_sql
        %Q{
        BEGIN
        DELETE FROM #{@current_table} WHERE uuid = NEW.uuid;
        DELETE FROM #{@current_table} WHERE internal_id = NEW.internal_id;
        INSERT INTO #{@current_table}(#{@columns.join(',')}) VALUES(#{new_values});
        END
        }
      end


      module MySQLTrigger
        def drop_trigger(name)
          DB.run "DROP TRIGGER IF EXISTS #{name}" 
        end

        def after_trigger(code, details)
          create_trigger(:after, code, details)
        end

        def create_trigger(at, code, details)
          DB.run "CREATE TRIGGER #{details[:name]} #{at.to_s.upcase} #{details[:event].to_s.upcase} ON #{details[:on]} FOR EACH ROW #{code}"
        end
        private :create_trigger
      end
      include MySQLTrigger
    end


    require_all('triggers/*.rb')

    # Map a model name to a trigger class
    # @example: {"aliquot" => Lims::WarehouseBuilder::Trigger::AliquotTrigger}
    ModelToTriggerClass = {}.tap do |h|
      constants.each do |constant|
        mod = const_get(constant)
        h[constant.to_s.match(/^([A-Z][a-z]+)Trigger$/)[1].downcase] = mod
      end
    end

    # @param [Class] klass
    # @return [BaseTrigger]
    def self.trigger_for(klass)
      model_name = klass.name.match(/::(\w+)$/)[1].downcase
      trigger_class = ModelToTriggerClass[model_name]
      trigger_class ? trigger_class.new(klass) : BaseTrigger.new(klass)
    end
  end
end
