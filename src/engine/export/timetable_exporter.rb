# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
require './src/engine/import/abstract_spreadsheet'
require './src/engine/models/lecturer'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class AbstractTimetableExporter
  Contract Any, IsA[AbstractSpreadsheet] => Any
  def initialize(entity, spreadsheet)
    raise NotImplementedError
  end

  Contract None => IsA[AbstractSpreadsheet]
  def export
    raise NotImplementedError
  end
end

class LecturerWeekTimetableExporter < AbstractTimetableExporter
  Contract IsA[Lecturer], IsA[AbstractSpreadsheet] => Any
  def initialize(lecturer, spreadsheet)
    @lecturer = lecturer
    @table = spreadsheet
  end

  Contract None => IsA[AbstractSpreadsheet]
  def export
    data = @lecturer.studies.group(:date, :number).group_by(&:date)
    @table[1, 1] = "Дата"
    @table[1, 2] = "Номер"
    @table[1, 3] = "Группа"
    @table[1, 4] = "Предмет"
    @table[1, 5] = "Кабинет"
    data.each_with_index do |date_studies, index_date|
      @table[index_date + 2, 1] = date_studies.first.to_s
      date_studies.last.each_with_index do |s, index|
        @table[index_date + index + 2, 2] = s.number
        @table[index_date + index + 2, 3] = s.groupable.title
        @table[index_date + index + 2, 4] = s.subject.title
        @table[index_date + index + 2, 5] = s.cabinet.title
      end
    end
    @table
  end
end
