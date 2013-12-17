require 'lims-warehousebuilder/spec_helper'
require 'lims-warehousebuilder/json_decoder'

module Lims::WarehouseBuilder::Decoder
  describe JsonDecoder do
    context "decoders" do
      it "gets the right decoder for sample" do
        described_class.decoder_for("sample").should == SampleDecoder
      end

      it "gets the right decoder for tube" do
        described_class.decoder_for("tube").should == TubeDecoder
      end

      it "gets the right decoder for order" do
        described_class.decoder_for("order").should == OrderDecoder
      end

      it "gets the right decoder for tube rack" do
        described_class.decoder_for("tube_rack").should == TubeRackDecoder
      end

      it "gets the right decoder for gel" do
        described_class.decoder_for("gel").should == GelDecoder
      end

      it "gets the right decoder for plate" do
        described_class.decoder_for("plate").should == JsonDecoder
      end

      it "gets the right decoder for filter paper" do
        described_class.decoder_for("filter_paper").should == JsonDecoder
      end

      it "gets the right decoder for barcode" do
        described_class.decoder_for("barcode").should == JsonDecoder
      end

      it "gets the right decoder for labellable" do
        described_class.decoder_for("labellable").should == LabellableDecoder
      end

      it "gets the right decoder for swap samples" do
        described_class.decoder_for("swap_samples").should == SwapSamplesDecoder
      end
    end
  end
end
