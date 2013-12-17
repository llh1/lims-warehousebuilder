require 'lims-warehousebuilder/models/common'

module Lims::WarehouseBuilder
  module Model
    class Barcode < Sequel::Model(DB[:historic_barcodes])
      
      include Helpers::Mapping
      include Common

      translate({
        :ean13 => :ean13_barcode,
        [:sanger__prefix, :sanger__number, :sanger__suffix] => :sanger_barcode
      })

      def self.barcode_by_sanger_barcode(value)
        barcode = self.dataset.from(current_table_name).where(:sanger_barcode => value).first
        raise NotFound, "The Sanger barcode #{value} cannot be found" unless barcode
        barcode
      end

      def self.barcode_by_ean13_barcode(value)
        barcode = self.dataset.from(current_table_name).where(:ean13_barcode => value).first
        raise NotFound, "The ean13 barcode #{value} cannot be found" unless barcode
        barcode
      end
    end
  end
end
