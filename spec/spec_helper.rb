ENV["LIMS_WAREHOUSEBUILDER_ENV"] = "test" unless defined?(ENV["LIMS_WAREHOUSEBUILDER_ENV"])
require 'yaml'
require 'timecop'
require 'sequel'
require 'lims-warehousebuilder/sequel'
require 'lims-warehousebuilder/base_trigger'
require 'lims-warehousebuilder/model'

# Triggers setup
module Lims::WarehouseBuilder
  Helpers::Database::S2_MODELS.each do |model_name|
    Trigger.trigger_for(Model.model_for(model_name)).setup
  end
end

shared_context 'use database' do
  let(:db) { DB }

  after(:each) do
    db[:sample_management_activity].delete
    db[:historic_tubes].delete
    db[:current_tubes].delete
    db.tables.each { |table| db[table.to_sym].delete }
    db.disconnect
  end
end

shared_context "timecop" do
  before do
    Timecop.freeze(Time.now.utc)
  end

  after do
    Timecop.return
  end
end
