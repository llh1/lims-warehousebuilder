require 'lims-warehousebuilder/models/common'

module Lims::WarehouseBuilder
  module Model
    class TubeRack < Sequel::Model(DB[:historic_tube_racks])
      
      include Helpers::Mapping
      include Common

      def self.tube_rack_by_uuid(uuid)
        Model.model_by_uuid(uuid, "tube_rack")
      end

      # @param [String] uuid
      # @return [Array]
      def self.children_uuids_for(uuid)
        tube_model = Model.model_for("tube")
        tubes = tube_model.dataset.from(
          tube_model.current_table_name
        ).select(:uuid).where(:tube_rack_uuid => uuid).all
        tubes.inject([]) { |m,e| m << e.uuid }
      end
    end
  end
end
