require 'lims-warehousebuilder/spec_helper'
require 'lims-warehousebuilder/builder'

shared_examples_for "a decoder" do
  it "can be called" do
    decoder.respond_to?(:call)
  end

  it "returns an array of sequel models" do
    decoder.call.should be_a(Array)
    decoder.call.each do |model|
      model.should be_a(Sequel::Model)
    end
  end
end
