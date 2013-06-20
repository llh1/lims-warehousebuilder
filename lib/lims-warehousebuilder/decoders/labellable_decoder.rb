require 'lims-warehousebuilder/json_decoder'

module Lims::WarehouseBuilder
  module Decoder
    class LabellableDecoder < JsonDecoder

      private

      def _call(options)
        barcodes
      end

      def barcodes
        barcoded_resource_uuid = @payload["name"]
        klass = Model.model_for("barcode")

        [].tap do |barcodes|
          @payload["labels"].each do |position, label|
            label_value = label["value"]
            begin
              barcode = case label["type"]
                        when /sanger/ then klass.barcode_by_sanger_barcode(label_value) 
                        when /ean13/ then klass.barcode_by_ean13_barcode(label_value)
                        end

              new_barcode = Model.clone_model_object(barcode)
              new_barcode.barcoded_resource_uuid = barcoded_resource_uuid
              new_barcode.position = position
              barcodes << new_barcode
            rescue Model::NotFound => e
              raise MessageToBeRequeued.new(e.message)
            end
          end
        end
      end
    end
  end
end
