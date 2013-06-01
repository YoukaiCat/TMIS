# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
require 'spreadsheet'
require 'benchmark'
require_relative '../import/abstract_spreadsheet'
require_relative '../models/lecturer'
require_relative '../models/group'
require_relative '../models/study'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class AbstractTimetableExportStratagy
  Contract Or[Range,Array] => Any
  def initialize(dates)
    raise NotImplementedError
  end

  Contract None => Or[Range,Array]
  def rows
    raise NotImplementedError
  end

  Contract None => Or[Range,Array]
  def columns
    raise NotImplementedError
  end

  Contract Any => Any
  def row_value(row_entity)
    raise NotImplementedError
  end

  Contract Any => Any
  def column_value(col_entity)
    raise NotImplementedError
  end

  Contract Any, Any => ArrayOf[Study]
  def studies(row_entity, col_entity)
    raise NotImplementedError
  end
end

class TimetableExporter
  Contract IsA[AbstractSpreadsheet], IsA[AbstractTimetableExportStratagy] => Any
  def initialize(table, stratagy)
    @table = table
    @stratagy = stratagy
  end

  Contract None => IsA[AbstractSpreadsheet]
  def export
    rows_export
    @table
  end

private
  def rows_export
    rows.each do |entity, rows|
      rows_format(rows)
      @table[rows[0] + 1, 1] = @stratagy.row_value(entity)
      (1..6).each do |row|
        pair_format(rows, row)
        @table[(rows[0] - 1) + row * 2, 2] = "#{row} пара"
      end
      columns_export(entity, rows)
    end
  end

  def columns_export(row_ent, rows)
    columns.each do |ent, cols|
      columns_format(rows, cols)
      @table[rows[0], cols[0]] = @stratagy.column_value(ent)
      export_studies(@stratagy.studies(row_ent, ent), rows, cols)
    end
  end

  Contract ArrayOf[Study], [Pos, Pos], [Pos, Pos] => Any
  def export_studies(studies, rows, cols)
    prepare_studies(studies).each do |number, studies|
      if studies.size == 1
        @table.merge(real_row(rows, number), cols[0], real_row(rows, number) + 1, cols[0])
        @table.merge(real_row(rows, number), cols[1], real_row(rows, number) + 1, cols[1])
      end
      studies.each_with_index do |study, i|
        @table[real_row(rows, number) + i, cols[0]] = study.to_s
        @table[real_row(rows, number) + i, cols[1]] = study.cabinet.title
      end
    end
  end

  def rows
    @stratagy.rows.zip((1..(13 * @stratagy.rows.to_a.size)).each_slice(13).map{ |i| [i.first, i.last] })
  end

  def columns
    @stratagy.columns.zip((3..(@stratagy.columns.to_a.size * 2) + (3 - 1)).each_slice(2))
  end

  #Contract ArrayOf[Study] => ({ Pos => ArrayOf[Study] })
  def prepare_studies(studies)
    studies.sort_by(&:number).group_by(&:number)
  end

  Contract ArrayOf[Pos], Pos => Pos
  def real_row(rows, number)
    (rows[0] - 1) + (number * 2)
  end

  def rows_format(rows)
    @table.merge(rows[0] + 1, 1, rows[1], 1)
    format = Spreadsheet::Format.new
    format.rotation = 90
    format.horizontal_align = :center
    format.vertical_align = :middle
    format.top = :medium
    format.bottom = :medium
    format.right = :medium
    format.left = :medium
    @table.format(rows[0] + 1, 1, format)
  end

  def pair_format(rows, row)
    @table.row((rows[0] - 1) + row * 2).height = 30
    @table.row(rows[0] + row * 2).height = 30
    @table.merge((rows[0] - 1) + row * 2, 2, rows[0] + row * 2, 2)
  end

  def columns_format(rows, cols)
    @table.column(cols[0]).width = 25
    @table.merge(rows[0], cols[0], rows[0], cols[1])
  end
end

class GeneralTimetableExportStratagy < AbstractTimetableExportStratagy
  Contract Or[Range,Array] => Any
  def initialize(dates)
    @dates = dates
  end

  Contract None => Or[Range,Array]
  def rows
    @dates
  end

  Contract None => Or[Range,Array]
  def columns
    Group.all.sort_by(&:title_for_sort)
  end

  Contract Any => Any
  def row_value(date)
    date.strftime('%A')
  end

  Contract Any => Any
  def column_value(group)
    group.title
  end

  Contract Any, Any => ArrayOf[Study]
  def studies(date, group)
    Study.of_group_and_its_subgroups(group).where(date: date).to_a
  end
end

class LecturerTimetableExportStratagy < AbstractTimetableExportStratagy
  Contract Or[Range,Array], Lecturer => Any
  def initialize(dates, lecturer)
    @dates = dates
    @lecturer = lecturer
  end

  Contract None => Or[Range,Array]
  def rows
    @dates
  end

  # TODO Изменить контракты
  Contract None => RespondTo[:zip]
  def columns
    Group.where(id: @lecturer.studies.where(date: @dates, groupable_type: 'Group').select(:groupable_id))
  end

  Contract Any => Any
  def row_value(date)
    date.strftime('%A')
  end

  Contract Any => Any
  def column_value(group)
    group.title
  end

  Contract Any, Any => ArrayOf[Study]
  def studies(date, group)
    Study.of_group_and_its_subgroups(group).where(date: date, lecturer_id: @lecturer).to_a
  end
end

class GroupTimetableExportStratagy < AbstractTimetableExportStratagy
  Contract Or[Range,Array], Group => Any
  def initialize(dates, group)
    @dates = dates
    @group = group
  end

  Contract None => Or[Range,Array]
  def rows
    ['']
  end

  Contract None => RespondTo[:zip]
  def columns
    @dates
  end

  Contract Any => Any
  def row_value(none)
    ""
  end

  Contract Any => Any
  def column_value(date)
    date.strftime('%A')
  end

  Contract Any, Any => ArrayOf[Study]
  def studies(none, date)
    Study.of_group_and_its_subgroups(@group).where(date: date).to_a
  end
end
