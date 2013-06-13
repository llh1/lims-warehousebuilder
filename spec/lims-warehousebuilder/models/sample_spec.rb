require 'lims-warehousebuilder/models/spec_helper'

module Lims::WarehouseBuilder
  describe "Sample" do
    include_context "use database"

    let(:model) { "sample" }
    let(:historic_table) { "historic_samples" }
    let(:current_table) { "current_samples" }
    let(:uuid) { "11111111-2222-3333-4444-555555555555" }
    let(:name) { "sample 0" }
    let(:created_at) { Time.now.utc }
    let(:created_by) { "username" }

    let(:object) do 
      @model.tap do |s|
        s.uuid = uuid
        s.created_at = created_at
        s.created_by = created_by
      end
    end

    let(:updated_object) do
      @model_helper.clone_model_object(object).tap do |s|
      end
    end

    it_behaves_like "a warehouse model"
  end
end
