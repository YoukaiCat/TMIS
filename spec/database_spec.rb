# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
require_relative '../src/engine/database'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
FactoryGirl.find_definitions

describe Database do
  #include DatabaseConnection
  it "must say true if connected" do
    $DB.connected?.should eq(true)
  end

  it "must have @path variable" do
    $DB.path.should eq(':memory:')
  end
end
