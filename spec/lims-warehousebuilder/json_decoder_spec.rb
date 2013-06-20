require 'lims-warehousebuilder/spec_helper'
require 'lims-warehousebuilder/json_decoder'

module Lims::WarehouseBuilder::Decoder
  describe JsonDecoder do
    let(:payload) { "{\"tube\":{\"actions\":{\"read\":\"http://localhost:9292/ab024060-7e68-0130-e2f8-282066132de2\",\"create\":\"http://localhost:9292/ab024060-7e68-0130-e2f8-282066132de2\",\"update\":\"http://localhost:9292/ab024060-7e68-0130-e2f8-282066132de2\",\"delete\":\"http://localhost:9292/ab024060-7e68-0130-e2f8-282066132de2\"},\"uuid\":\"ab024060-7e68-0130-e2f8-282066132de2\",\"type\":\"eppendorf\",\"max_volume\":100,\"aliquots\":[{\"sample\":{\"actions\":{\"read\":\"http://localhost:9292/aaff8000-7e68-0130-e2fa-282066132de2\",\"create\":\"http://localhost:9292/aaff8000-7e68-0130-e2fa-282066132de2\",\"update\":\"http://localhost:9292/aaff8000-7e68-0130-e2fa-282066132de2\",\"delete\":\"http://localhost:9292/aaff8000-7e68-0130-e2fa-282066132de2\"},\"uuid\":\"aaff8000-7e68-0130-e2fa-282066132de2\",\"name\":\"sample_0\"},\"quantity\":1000,\"type\":\"NA+P\",\"unit\":\"mole\"}]},\"action\":\"create\",\"date\":\"2013-04-03 08:44:49 UTC\",\"user\":\"user\"}" } 

    context "decode payload" do
      let(:expected_models) { ["tube", "sample"] }
      before(:each) do
        @resources = {} 
        described_class.foreach_s2_resource(payload) do |model, attributes|
          @resources[model] = attributes
        end
      end

      it "find the right number of resources" do
        @resources.keys.size.should == expected_models.size
      end

      it "find the right resource models" do
        @resources.keys.each do |model|
          expected_models.should include(model)
        end
      end

      context "nested resource" do
        let(:expected_attributes) { ["ancestor_type", "ancestor_uuid"].merge(described_class::SHARED_ATTRIBUTES) }
        it "contains the necessary attributes in the decoded payload" do
          expected_attributes.each do |attribute|
            @resources["sample"].keys.should include(attribute)
          end
        end
      end
    end

    context "decoders" do
      it "gets the right decoder for sample" do
        described_class.decoder_for("sample").should == SampleDecoder
      end

      it "gets the right decoder for tube" do
        described_class.decoder_for("tube").should == JsonDecoder
      end

      it "gets the right decoder for order" do
        described_class.decoder_for("order").should == OrderDecoder
      end

      it "gets the right decoder for tube rack" do
        described_class.decoder_for("tube_rack").should == JsonDecoder
      end

      it "gets the right decoder for barcode" do
        described_class.decoder_for("barcode").should == JsonDecoder
      end

      it "gets the right decoder for labellable" do
        described_class.decoder_for("labellable").should == LabellableDecoder
      end
    end

    context "map attributes to a model" do
      let(:model) { Model::Tube.new }
      let(:mapped_model) { described_class.new.map_attributes_to_model(model, payload) }
      pending    
    end
  end
end
