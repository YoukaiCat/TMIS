# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'roo'
require 'fileutils'
require 'spreadsheet'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#require '#Contracts'
require_relative 'abstract_spreadsheet'
#include #Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class SpreadsheetRoo < AbstractSpreadsheet

  attr_reader :filepath

  ##Contract String => Any
  def initialize(filepath)
    @filepath = filepath.force_encoding("UTF-8")
    @sheet = Roo::Spreadsheet.open(@filepath)
    @sheet.default_sheet = 0
  end

  #Contract None => Pos
  def last_row
    @sheet.last_row
  end

  #Contract None => Pos
  def last_column
    @sheet.last_column
  end

  #Contract Not[Neg] => Any
  def sheet(number)
    @sheet.default_sheet = @sheet.sheets[number-1]
  end

  #Contract Pos => Any
  def row(n)
    @sheet.row(n)
  end

  #Contract Pos => Any
  def column(n)
    @sheet.column(n)
  end

  #Contract Pos, Pos => Any
  def [](r, c)
    @sheet.cell(r, c)
  end
end

class SpreadsheetSpreadsheet < AbstractSpreadsheet
  include WritableSpreadsheet

  attr_reader :filepath

  #Contract String => Any
  def initialize(filepath)
    @filepath = filepath.force_encoding("UTF-8")
    Spreadsheet.client_encoding = 'UTF-8'
    if File.file?(@filepath)
      @book = Spreadsheet.open(@filepath)
    else
      @book = Spreadsheet::Workbook.new(@filepath)
      @book.create_worksheet
    end
    @sheet = @book.worksheet(0)
    fmt = Spreadsheet::Format.new text_wrap: true
    fmt.horizontal_align = :center
    fmt.vertical_align = :middle
    fmt.font = Spreadsheet::Font.new('Times New Roman', :size => 12)
    @sheet.default_format = fmt
    @sheet
  end

  #Contract None => Pos
  def last_row
    @sheet.last_row_index
  end

  #Contract None => Pos
  def last_column
    @sheet.column_count
  end

  #Contract Not[Neg] => Any
  def sheet(number)
    @sheet = @book.worksheet(number - 1)
  end

  #Contract Pos => Any
  def row(n)
    @sheet.row(n - 1)
  end

  #Contract Pos => Any
  def column(n)
    @sheet.column(n - 1)
  end

  #Contract Pos, Pos => Any
  def [](r, c)
    @sheet[r - 1, c - 1]
  end

  #Contract Pos, Pos, Any => Any
  def []=(r, c, obj)
    @sheet[r - 1, c - 1] = obj
  end

  #Contract None => Any
  def save
    @book.write("#{@filepath}_temp")
    FileUtils.mv("#{@filepath}_temp", @filepath) # Обход бага в библиотеке
  end

  def merge(start_row, start_col, end_row, end_col)
    @sheet.merge_cells(start_row - 1, start_col - 1, end_row - 1, end_col - 1)
  end

  def format(r, c, fmt)
    @sheet.row(r - 1).set_format(c - 1, fmt)
  end
end

class SpreadsheetCreater
  #Contract String => Or[IsA[AbstractSpreadsheet], IsA[WritableSpreadsheet]]
  def self.create(filename)
    filename = filename.force_encoding("UTF-8")
    if filename =~ /.*.csv/
      SpreadsheetRoo.new(File.expand_path(filename))
    else
      SpreadsheetSpreadsheet.new(File.expand_path(filename))
    end
  end
end
