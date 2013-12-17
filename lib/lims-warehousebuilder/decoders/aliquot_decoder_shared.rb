require 'lims-warehousebuilder/models/aliquot'

module Lims::WarehouseBuilder
  module Decoder
    module AliquotDecoderShared

      # @param [Hash] aliquots
      # @param [String] position
      # @return [Array<Model::Aliquot>]
      def decode_aliquots(aliquots, position=nil)
        [].tap do |decoded_aliquots|
          aliquots.each do |aliquot|
            # if there is no sample associated to the aliquot, it usually 
            # means the aliquot is the solvent
            sample_uuid = aliquot["sample"]["uuid"] if aliquot["sample"]
            aliquot_model = Model::Aliquot.new_for(@uuid, position, sample_uuid)
            quantity, type = aliquot["quantity"], aliquot["type"]

            # The concentration information is contained as an out_of_bounds parameter and not
            # part of a stored aliquot in s2. As a result, when we update an aliquot, the 
            # concentration might not be set and be nil. To keep it consistent in the warehouse,
            # we set the concentration back from the warehouse model, so it's not updated to nil.
            concentration = aliquot["out_of_bounds"] ? aliquot["out_of_bounds"]["concentration"] : aliquot_model.concentration

            payload_aliquot_attributes = {
              "container_uuid" => @uuid, "position" => position,
              "sample_uuid" => sample_uuid, "quantity" => quantity,
              "type" => type, "concentration" => concentration,
              "date" => @date, "user" => @user
            }

            new_aliquot_model = map_attributes_to_model(aliquot_model, payload_aliquot_attributes)
            decoded_aliquots << new_aliquot_model if new_aliquot_model
          end
        end
      end
    end
  end
end
