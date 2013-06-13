require 'lims-warehousebuilder/models/spec_helper'

module Lims::WarehouseBuilder
  describe "Sample management activity" do
    include_context "use database"

    let(:model) { "sample_management_activity" }
    let(:historic_table) { "historic_sample_management_activity" }
    let(:current_table) { "current_sample_management_activity" }
    let(:uuid) { "11111111-2222-3333-4444-555555555555" }
    let(:item_uuid) { "11111111-2222-3333-4444-666666666666" }
    let(:created_at) { Time.now.utc }
    let(:created_by) { "username" }

    let(:object) do 
      @model.tap do |s|
        s.uuid = uuid
      end
    end

    let(:updated_object) do
      @model_helper.clone_model_object(object).tap do |s|
        s.manual_dnr_input_tube_nap_uuid = item_uuid 
        s.manual_dnr_input_tube_nap_pending_by = created_by
        s.manual_dnr_input_tube_nap_pending_at = created_at
      end
    end

    it_behaves_like "a warehouse model"

    context "dispatch attributes" do
      let(:role) { "manual_dna_and_rna_input_tube_nap" }
      let(:status) { "in_progress" }
      let(:at) { Time.now.utc }
      let(:by) { "username" }
      let(:activity) { Model::SampleManagementActivity.new(:uuid => uuid) }

      before(:each) do
        activity.dispatch_attributes(item_uuid, role, status, at, by)
      end

      context "valid" do
        it "sets the item role uuid" do
          activity.manual_dnr_input_tube_nap_uuid.should == item_uuid
        end

        it "sets the date" do
          activity.manual_dnr_input_tube_nap_in_progress_at.to_s.should == at.to_s
        end

        it "sets the username" do
          activity.manual_dnr_input_tube_nap_in_progress_by.should == by
        end
      end

      context "invalid" do
        let(:newer_at) { at + 60 }
        let(:older_at) { at - 60 }

        it "doesn't update the group of fields if the date is more recent" do
          activity.dispatch_attributes(item_uuid, role, status, newer_at.to_s, by).manual_dnr_input_tube_nap_in_progress_at.to_s.should == at.to_s
        end

        it "updates the group of fields if the date is older" do
          activity.dispatch_attributes(item_uuid, role, status, older_at.to_s, by).manual_dnr_input_tube_nap_in_progress_at.to_s.should == older_at.to_s
        end
      end
    end
  end
end
