class AbstractSpreadsheet

  def last_row
    raise NotImplementedError
  end

  def last_column
    raise NotImplementedError
  end

  def sheet(n)
    raise NotImplementedError
  end

  def row
    raise NotImplementedError
  end

  def column
    raise NotImplementedError
  end

  def [](r, c)
    raise NotImplementedError
  end

end
