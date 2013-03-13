require 'rspec'
require 'config'
require './src/engine/import/timetable_reader'
require './src/engine/import/spreadsheet_roo'

describe TimetableReader do

  it "mustn't raise exception" do
    expect do
      TimetableReader.new(SpreadsheetRoo.new("./spec/import/test_data/raspisanie_2013.csv"))
    end.to_not raise_error
  end

end
