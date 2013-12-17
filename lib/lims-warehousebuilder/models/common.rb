module Lims::WarehouseBuilder
  module Model
    module Common
      # The attribute created_at can be set only one time.
      # The other time, when we try to set a new value in
      # created_at, it is actually set in updated_at.
      def created_at=(value)
        (self.respond_to?(:updated_at) && self.created_at) ? self.updated_at = value : super(value)
      end

      # Same behaviour with created_at=
      def created_by=(value)
        (self.respond_to?(:updated_by) && self.created_by) ? self.updated_by = value : super(value)
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def current_table_name
          self.table_name.to_s =~ /historic/ ? self.table_name.to_s.sub(/historic/, "current") : default_table_name 
        end

        def default_table_name
          self.table_name.to_s
        end
      end
    end
  end
end
