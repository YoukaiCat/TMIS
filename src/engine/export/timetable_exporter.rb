# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
require_relative '../import/abstract_spreadsheet'
require_relative '../models/lecturer'
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
    @table[1, 1] = 'Дата'
    @table[1, 2] = 'Номер'
    @table[1, 3] = 'Группа'
    @table[1, 4] = 'Предмет'
    @table[1, 5] = 'Кабинет'
    index = 2
    for date_studies in data
      @table[index, 1] = date_studies.first.to_s
      date_studies.last.each_with_index do |s, sindex|
        @table[index + sindex, 2] = s.number
        @table[index + sindex, 3] = s.groupable.title
        @table[index + sindex, 4] = s.subject.title
        @table[index + sindex, 5] = s.cabinet.title
      end
      index += date_studies.last.size
    end
    @table
  end
end
