require 'lims-warehousebuilder/spec_helper'
require 'lims-warehousebuilder/sequel'
require 'lims-warehousebuilder/helpers'

module Lims::WarehouseBuilder::Helpers
  describe "Nested Hash" do
    let(:nested_hash) { {:a => 1, :b => {:c => 2, :d => {:e => [3], :f => {"uuid" => "456"}}, :g => 5}, :h => {"uuid" => "123"}, :i => nil} }
    let(:object) { Class.new { include NestedHash }.new }

    context "seek" do
      it "seeks the value of :e in the hash" do
        object.seek(nested_hash, "b__d__e").should == [3]
      end

      it "seeks the value of :g in the hash" do
        object.seek(nested_hash, "b__g").should == 5
      end

      it "seeks the value of :h in the hash" do
        object.seek(nested_hash, "h").should == {"uuid" => "123"}
      end

      it "seeks the value of inexistant key" do
        object.seek(nested_hash, "i__z").should == nil
      end
    end

    context "parent_key_for_uuid" do
      it "gets the parent key for hash containing uuid 456" do
        object.parent_key_for_uuid("456", nested_hash).should == :f
      end

      it "gets the parent key for hash containing uuid 123" do
        object.parent_key_for_uuid("123", nested_hash).should == :h
      end

      it "returns nil if the uuid is not found" do
        object.parent_key_for_uuid("dummy", nested_hash).should == nil
      end
    end
  end
end
