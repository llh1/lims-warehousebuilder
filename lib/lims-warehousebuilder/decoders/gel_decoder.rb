require 'lims-warehousebuilder/json_decoder'
require 'lims-warehousebuilder/decoders/aliquot_decoder_shared'

module Lims::WarehouseBuilder
  module Decoder
    class GelDecoder < JsonDecoder
      include AliquotDecoderShared
      
      def _call(options)
        [super, gel_aliquots]
      end

      private

      # @return [Array<Model::Aliquot>]
      def gel_aliquots
        [].tap do |decoded_aliquots|
          @payload["windows"].each do |position, aliquots|
            decoded_aliquots << decode_aliquots(aliquots, position)
          end
        end
      end
    end
  end
end
