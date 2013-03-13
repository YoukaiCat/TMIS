require 'rspec'
require 'config'
require './src/engine/import/spreadsheet_roo'

describe SpreadsheetRoo do

  before(:all) do
    class SpreadsheetRoo
      def sheet(number)
        @s.default_sheet = 0
      end
    end
  end

  it "mustn't raise exception" do
    expect do
      SpreadsheetRoo.new("./spec/import/test_data/raspisanie_2013.csv")
    end.to_not raise_error
  end

end
