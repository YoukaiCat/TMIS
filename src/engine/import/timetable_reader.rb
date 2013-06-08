# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
require_relative 'abstract_spreadsheet'
require_relative '../../interface/forms/settings'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class TimetableReader
  Contract IsA[AbstractSpreadsheet], Pos => Any
  def initialize(spreadsheet, sheet_number=1)
    @table = spreadsheet
    week(sheet_number)
  end

  Contract Pos => TimetableReader
  def week(num)
    @table.sheet(num); self
  end

  Contract None => Array
  def groups
    (3..@table.last_column).each_slice(2).map do |cols|
      { title: @table[7, cols.first], days: get_days(cols) }
    end
  end

private
  Contract [Pos, Pos] => Array
  def get_days(cols)
    (7..84).each_slice(13).map{ |i| [i[1], i.last] }.map do |rows|
      { name: @table[rows.first, 1], studies: get_studies(rows, cols) }
    end
  end

  Contract [Pos, Pos], [Pos, Pos] => Array
  def get_studies(rows, cols)
    (rows.first..rows.last).each_slice(2).map do |study_rows|
      study_rows.map do |row|
        { info: parse_info(@table[row, cols.first]), cabinet: @table[row, cols.last] }
      end.reject{ |s| s[:info].nil? }
    end
  end

  Contract Maybe[String] => Maybe[Hash]
  def parse_info(info)
    unless info.nil?
      info[/(.*)\s{2,}(([[:alpha:]]+)\s+([[:alpha:]]).\s?([[:alpha:]])|#{Settings[:stubs, :lecturer]})(.+?(\d))?/i]
      if $1 && $3 && $4 && $5
        { subject: ($1.strip), lecturer: { surname: $3, name: $4, patronymic: $5 }, subgroup: $7 }
      elsif $1 && $2
        { subject: ($1.strip), lecturer: { surname: $2, name: nil, patronymic: nil }, subgroup: $7 }
      end
    end
  end
end
