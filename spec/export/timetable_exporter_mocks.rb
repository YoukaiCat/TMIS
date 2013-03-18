class MockNotImplementedExporter <  AbstractTimetableExporter
end

class MockSpreadsheet < AbstractSpreadsheet
  def initialize
    @sheet = [[nil]]
  end

  def [](row, col)
    @sheet[row - 1][col - 1]
  end

  def []=(row, col, object)
    @sheet[row - 1] = [] if @sheet[row - 1].nil?
    @sheet[row - 1][col - 1] = object
  end

  def save(name)
  end
end
