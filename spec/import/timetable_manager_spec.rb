# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/import/timetable_manager'
require_relative '../../src/engine/import/timetable_reader'
require_relative '../../src/engine/import/spreadsheet_roo'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
#describe TimetableManager do
#  it "mustn't raise exception" do
#    expect do
#      TimetableManager.new(TimetableReader.new(SpreadsheetFabric.create("./spec/import/test_data/raspisanie_2013.csv"), 1), Date.parse('monday')).save_to_db
#    end.to_not raise_error
#  end
#end
