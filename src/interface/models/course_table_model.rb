# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/course'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class CourseTableModel < Qt::AbstractTableModel

  def initialize(courses, parent)
    super()
    @courses = courses
    @view = parent
  end

  def rowCount(parent)
    @courses.size
  end

  def columnCount(parent)
    1
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    course = @courses[index.row]
    return invalid if course.nil?
    v = case index.column
        when 0
          course.number
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
          %w(Номер)[section]
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
      course = @courses[index.row]
      case index.column
      when 0
        course.number = s.to_i
      else
        raise "invalid column #{index.column}"
      end
      course.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    beginInsertRows(createIndex(0, 0), 0, 0)
    @courses.prepend(Course.new)
    emit dataChanged(createIndex(0, 0), createIndex(@courses.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @courses[@view.currentIndex.row].try(:delete)
      @courses.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@courses.size, 1))
    end
  end

end
