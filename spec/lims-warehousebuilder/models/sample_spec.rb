require 'lims-warehousebuilder/models/spec_helper'

module Lims::WarehouseBuilder
  describe Model::Sample do
    include_context "use database"
    include_context "timecop"

    let(:model) { "sample" }
    let(:uuid) { "11111111-2222-3333-4444-555555555555" }
    let(:name) { "sample 0" }
    let(:created_at) { Time.now.utc }
    let(:created_by) { "username" }

    let(:object) do 
      Model.model_for(model).new.tap do |s|
        s.uuid = uuid
        s.created_at = created_at
        s.created_by = created_by
      end
    end

    let(:updated_object) do
      Model.clone_model_object(object)
    end

    it_behaves_like "a warehouse model"

    it "returns a sample given its uuid" do
      object.save
      described_class.sample_by_uuid(uuid).should be_a(Model::Sample)
      (described_class.sample_by_uuid(uuid).values - [:internal_id]).should == (object.values - [:internal_id]) 
    end

    it "raises an error if the sample cannot be found" do
      expect do
        described_class.sample_by_uuid(uuid)
      end.to raise_error(Model::NotFound)
    end
  end
end
