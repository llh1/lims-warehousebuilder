require 'lims-warehousebuilder/models/common'
require 'lims-warehousebuilder/helpers'

module Lims::WarehouseBuilder
  module Model
    class Aliquot < Sequel::Model(DB[:historic_aliquots])

      include Common
      include Helpers::Mapping

      # @param [String] container_uuid
      # @param [Integer] position
      # @param [String] sample_uuid
      # @return [Model::Aliquot]
      # Returns a new instance of an aliquot model preloaded
      # with the aliquot in DB corresponding to the triple
      # container_uuid, position and sample_uuid.
      def self.new_for(container_uuid, position, sample_uuid)
        loaded_aliquot = self.from(current_table_name).where({
          :container_uuid => container_uuid,
          :position => position,
          :sample_uuid => sample_uuid
        }).first
       
        values = loaded_aliquot ? loaded_aliquot.values - [:internal_id] : {}
        self.new(values)
      end
    end
  end
end
