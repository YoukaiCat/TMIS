# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
require 'spreadsheet'
require_relative '../import/abstract_spreadsheet'
require_relative '../models/lecturer'
require_relative '../models/group'
require_relative '../models/study'
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

class GeneralWeekTimetableExporter < AbstractTimetableExporter
  Contract Any, IsA[AbstractSpreadsheet] => Any
  def initialize(days, spreadsheet)
    @days = days.to_a
    @table = spreadsheet
  end

  Contract None => IsA[AbstractSpreadsheet]
  def export
    rows = (1..(13*6)).each_slice(13).map{ |i| [i.first, i.last] }
    dr = @days.zip(rows)
    groups = Group.all.shuffle.sort_by(&:title_for_sort)
    cols = (3..(groups.size*2)+(3-1)).each_slice(2)
    gc = groups.zip(cols)
    dr.each do |date, rows|
      @table.merge(rows[0]+1, 1, rows[1], 1)
      format = Spreadsheet::Format.new
      format.rotation = 90
      format.horizontal_align = :center
      format.vertical_align = :middle
      format.top = :medium
      format.bottom = :medium
      format.right = :medium
      format.left = :medium
      @table.format(rows[0]+1, 1, format)
      @table[rows[0]+1, 1] = date.strftime('%A')
      (1..6).each do |row|
        @table.row((rows[0] - 1) + row * 2).height = 30
        @table.row(rows[0] + row * 2).height = 30
        @table.merge((rows[0] - 1) + row * 2, 2, rows[0] + row * 2, 2)
        @table[(rows[0] - 1) + row * 2, 2] = "#{row} пара"
      end
      gc.each do |group, cols|
        @table.column(cols[0]).width = 25
        @table.merge(rows[0], cols[0], rows[0], cols[1])
        @table[rows[0], cols[0]] = group.title
        (group.studies.where(date: date) + group.subgroups.map{ |s| s.studies.where(date: date) })
        .flatten.sort_by(&:number).group_by(&:number).each do |number, studies|
          if studies.size == 1
            @table.merge((rows[0]-1) + (number * 2), cols[0], (rows[0]-1) + (number * 2) + 1, cols[0])
            @table.merge((rows[0]-1) + (number * 2), cols[1], (rows[0]-1) + (number * 2) + 1, cols[1])
          end
          studies.each_with_index do |study, i|
            @table[(rows[0]-1) + (number * 2) + i, cols[0]] = study.to_s
            @table[(rows[0]-1) + (number * 2) + i, cols[1]] = study.cabinet.title
          end
        end
      end
    end
    @table
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
