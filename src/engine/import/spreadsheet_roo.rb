# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'roo'
require 'fileutils'
require 'spreadsheet'
require './src/engine/import/abstract_spreadsheet'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
require './src/engine/import/abstract_spreadsheet'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SpreadsheetRoo < AbstractSpreadsheet

  attr_reader :filepath

  Contract String => Any
  def initialize(filepath)
    @filepath = filepath
    @sheet = Roo::Spreadsheet.open(filepath)
    @sheet.default_sheet = 0
  end

  Contract None => Pos
  def last_row
    @sheet.last_row
  end

  Contract None => Pos
  def last_column
    @sheet.last_column
  end

  Contract Not[Neg] => Any
  def sheet(number)
    @sheet.default_sheet = @sheet.sheets[number]
  end

  Contract Pos => Any
  def row(n)
    @sheet.row(n)
  end

  Contract Pos => Any
  def column(n)
    @sheet.column(n)
  end

  Contract Pos, Pos => Any
  def [](r, c)
    @sheet.cell(r, c)
  end
end

class SpreadsheetSpreadsheet < AbstractSpreadsheet
  include WritableSpreadsheet

  attr_reader :filepath

  Contract String => Any
  def initialize(filepath)
    @filepath = filepath
    if File.file?(@filepath)
      @book = Spreadsheet.open(@filepath)
    else
      @book = Spreadsheet::Workbook.new(@filepath)
      @book.create_worksheet
    end
    @sheet = @book.worksheet(0)
  end

  Contract None => Pos
  def last_row
    @sheet.last_row_index
  end

  Contract None => Pos
  def last_column
    @sheet.column_count
  end

  Contract Not[Neg] => Any
  def sheet(number)
    @sheet = @book.worksheet(number)
  end

  Contract Pos => Any
  def row(n)
    @sheet.row(n - 1)
  end

  Contract Pos => Any
  def column(n)
    @sheet.column(n - 1)
  end

  Contract Pos, Pos => Any
  def [](r, c)
    @sheet[r - 1, c - 1]
  end

  Contract Pos, Pos, Any => Any
  def []=(r, c, obj)
    @sheet[r - 1, c - 1] = obj
  end

  Contract None => Any
  def save
    @book.write("#{@filepath}_temp")
    FileUtils.mv("#{@filepath}_temp", @filepath) # Обход бага в библиотеке
  end
end

class SpreadsheetCreater
  Contract String => Or[IsA[AbstractSpreadsheet], IsA[WritableSpreadsheet]]
  def self.create(filename)
    if filename =~ /.*.csv/
      SpreadsheetRoo.new(File.expand_path(filename))
    else
      SpreadsheetSpreadsheet.new(File.expand_path(filename))
    end
  end
end
