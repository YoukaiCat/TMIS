# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require_relative '../config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative 'timetable_importer_mocks'
require 'tmis/engine/import/spreadsheet_roo'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe MockNotImplementedSpreadsheet do
  let(:ssheet) { MockNotImplementedSpreadsheet.new('') }

  it 'should raise exception if method not imlemented' do
    expect { ssheet.last_row }.to raise_error
  end

  it 'should raise exception if method not imlemented' do
    expect { ssheet.last_column }.to raise_error
  end

  it 'should raise exception if method not imlemented' do
    expect { ssheet.sheet(5) }.to raise_error
  end

  it 'should raise exception if method not imlemented' do
    expect { ssheet.row }.to raise_error
  end

  it 'should raise exception if method not imlemented' do
    expect { ssheet.column }.to raise_error
  end

  it 'should raise exception if method not imlemented' do
    expect { ssheet[1, 1] }.to raise_error
  end
end

describe SpreadsheetCreater do
  it "mustn't raise exception" do
    expect do
      SpreadsheetCreater.create('./spec/import/test_data/raspisanie_2013.csv')
    end.to_not raise_error
  end

  it 'should create SpreadsheetRoo' do
    concrete_spreadsheet = SpreadsheetCreater.create('./spec/import/test_data/raspisanie_2013.csv')
    concrete_spreadsheet.class.should eq(SpreadsheetRoo)
  end
end
