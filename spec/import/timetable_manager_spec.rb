# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require './src/engine/import/timetable_manager'
require './src/engine/import/timetable_reader'
require './src/engine/import/spreadsheet_roo'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
#describe TimetableManager do
#  it "mustn't raise exception" do
#    expect do
#      TimetableManager.new(TimetableReader.new(SpreadsheetFabric.create("./spec/import/test_data/raspisanie_2013.csv"), 0)).save_to_db
#    end.to_not raise_error
#  end
#end