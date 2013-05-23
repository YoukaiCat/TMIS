# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/import/timetable_reader'
require_relative '../../src/engine/import/spreadsheet_roo'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe TimetableReader do
  before(:all) do
    @sheet = SpreadsheetCreater.create("./spec/import/test_data/raspisanie_2013.csv")
  end

  it "mustn't raise exception" do
    expect { TimetableReader.new(@sheet, 1) }.to_not raise_error
  end

  it 'must raise exception' do
    expect { TimetableReader.new(@sheet, 0) }.to raise_error
  end

  it 'must parse info right' do
    TimetableReader.new(@sheet, 1).parse_info('').should eq(nil)
    TimetableReader.new(@sheet, 1).parse_info('invalid').should eq(nil)
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   Куплинова Е.Д.(2п)')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'Куплинова', name: 'Е', patronymic: 'Д' }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   Куплинова Е.Д.')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'Куплинова', name: 'Е', patronymic: 'Д' }, subgroup: nil })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   вакансия (2п)')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: '2' })
    res = TimetableReader.new(@sheet, 1).parse_info('Информатика и ИКТ   вакансия')
    res.should eq({ subject: 'Информатика и ИКТ', lecturer: { surname: 'вакансия', name: nil, patronymic: nil }, subgroup: nil })
  end
end
