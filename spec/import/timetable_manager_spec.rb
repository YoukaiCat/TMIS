# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require_relative '../config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'tmis/engine/import/timetable_manager'
require 'tmis/engine/import/timetable_reader'
require 'tmis/engine/import/spreadsheet_roo'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
#describe TimetableManager do
#  it "mustn't raise exception" do
#    expect do
#      TimetableManager.new(TimetableReader.new(SpreadsheetFabric.create("./spec/import/test_data/raspisanie_2013.csv"), 1), Date.parse('monday')).save_to_db
#    end.to_not raise_error
#  end
#end
