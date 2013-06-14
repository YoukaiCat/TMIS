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
    unless info.nil? || info.empty?
      info = info.split(/[\s\n\.\(\)]/).reverse.join(' ')
      r = /(\p{Ll}*\s*(?<subgroup>[[:digit:]])\s*\p{Ll}*\s*)?((?<patronymic>[[:upper:]])\s(?<name>[[:upper:]]))?\s*(?<surname>([[:upper:]][[:alpha:]]+|[Вв]акансия))?\s*(?<title>.*)/mx
      data = r.match(info.strip)
      { subject: data[:title].split.reverse.join(' ').strip, lecturer: { surname: data[:surname], name: data[:name], patronymic: data[:patronymic] }, subgroup: data[:subgroup] }
    end
  end
end
