# coding: UTF-8

require 'rspec'
require 'config'
require './src/engine/database'

FactoryGirl.find_definitions

describe Database do
  it "must successfully connect" do
    @db = Database.new("sqlite3", ":memory:") #Timetable.db
    expect { @db.connect }.to_not raise_error
  end
end
