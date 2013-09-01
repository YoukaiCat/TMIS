# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
#include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class AbstractSpreadsheet
  #Contract String => Any
  def initialize(filepath)
    raise NotImplementedError
  end

  #Contract None => Pos
  def last_row
    raise NotImplementedError
  end

  #Contract None => Pos
  def last_column
    raise NotImplementedError
  end

  #Contract Not[Neg] => Any
  def sheet(n)
    raise NotImplementedError
  end

  #Contract Pos => Any
  def row(n)
    raise NotImplementedError
  end

  #Contract Pos => Any
  def column(n)
    raise NotImplementedError
  end

  #Contract Pos, Pos => Any
  def [](r, c)
    raise NotImplementedError
  end
end

module WritableSpreadsheet
  #Contract Pos, Pos, Any => Any
  def []=(r, c, obj)
    raise NotImplementedError
  end

  #Contract None => Any
  def save
    raise NotImplementedError
  end
end
