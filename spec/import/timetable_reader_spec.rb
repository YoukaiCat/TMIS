# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require './src/engine/import/timetable_reader'
require './src/engine/import/spreadsheet_roo'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe TimetableReader do
  before(:all) do
    @sheet = SpreadsheetCreater.create("./spec/import/test_data/raspisanie_2013.csv")
  end

  it "mustn't raise exception" do
    expect { TimetableReader.new(@sheet, :first!) }.to_not raise_error
  end

  it "must raise exception" do
    expect { TimetableReader.new(@sheet, :test) }.to raise_error
  end
end
