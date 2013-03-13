require 'roo'
require './src/engine/import/abstract_spreadsheet'

class SpreadsheetRoo < AbstractSpreadsheet

  def initialize(filepath)
    @s = Roo::Spreadsheet.open(filepath)
  end

  def last_row
    @s.last_row
  end

  def last_column
    @s.last_column
  end

  def sheet(number)
    @s.default_sheet = @s.sheets[number]
  end

  def row
    @s.row
  end

  def column
    @s.column
  end

  def [](r, c)
    @s.cell(r, c)
  end

end
