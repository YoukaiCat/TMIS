require 'rspec'
require 'config'
require './src/engine/import/timetable_manager'
require './src/engine/import/timetable_reader'
require './src/engine/import/spreadsheet_roo'

describe TimetableManager do

  before(:all) do
    class SpreadsheetRoo
      def sheet(number)
        @s.default_sheet = 0
      end
    end
  end

  it "mustn't raise exception" do
    expect do
     TimetableManager.new(TimetableReader.new(SpreadsheetRoo.new("./spec/import/test_data/raspisanie_2013.csv"))).save_to_db
    end.to_not raise_error
  end

end
