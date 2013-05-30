# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/export/timetable_exporter'
require_relative 'timetable_exporter_mocks'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
#describe AbstractTimetableExporter do
#  it 'should raise exception if methods not imlemented' do
#    expect { MockNotImplementedExporter.new(nil, nil).export }.to raise_error
#  end
#end
#
#describe LecturerWeekTimetableExporter do
#  let(:exporter) { LecturerWeekTimetableExporter.new(Lecturer.find(2), MockSpreadsheet.new) }
#  it 'should ...' do
#    sheet = exporter.export
#    sheet[1, 1].should eq('Дата')
#    sheet[1, 2].should eq('Номер')
#    sheet[1, 3].should eq('Группа')
#    sheet[1, 4].should eq('Предмет')
#    sheet[1, 5].should eq('Кабинет')
#  end
#
#  it 'should generate timetable for lecturer' do
#    expect do
#      filename = 'NewTimetable.xls'
#      spreadsheet = SpreadsheetCreater.create(filename)
#      LecturerWeekTimetableExporter.new(Lecturer.find(2), spreadsheet).export.save
#      File.delete(filename)
#    end.to_not raise_error
#  end
#end
