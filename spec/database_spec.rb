# coding: UTF-8

require 'rspec'
require 'config'
require './src/engine/database'

FactoryGirl.find_definitions

describe Database do
  it "must successfully connect" do
    expect { Database.instance.connect_to(':memory:') }.to_not raise_error
  end

  it "must say true if connected" do
    Database.instance.connected?.should eq(true)
  end

  it "must have @path variable" do
    Database.instance.path.should eq(':memory:')
  end
end
