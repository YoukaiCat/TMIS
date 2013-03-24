# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require './src/engine/models/semester'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SemesterTableModel < Qt::AbstractTableModel

  def initialize(semesters)
    super()
    @semesters = semesters
  end

  def rowCount(parent)
    @semesters.size
  end

  def columnCount(parent)
    2
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    semester = @semesters[index.row]
    return invalid if semester.nil?
    v = case index.column
        when 0
          semester.title
        when 1
          semester.course.number
        else
          raise "invalid column #{index.column}"
        end || ''
    Qt::Variant.new(v)
  end

  def headerData(section, orientation, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole
    v = case orientation
        when Qt::Horizontal
          %w(Название Курс)[section]
        else
          ''
        end
    Qt::Variant.new(v)
  end

  def flags(index)
    Qt::ItemIsEditable | super(index)
  end

  def setData(index, variant, role = Qt::EditRole)
    if index.valid? and role == Qt::EditRole
      s = variant.toString
      semester = @semesters[index.row]
      case index.column
      when 0
        semester.title
      when 1
        semester.course.number
      else
        raise "invalid column #{index.column}"
      end
      semester.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

end
