# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/course'
require 'tmis/interface/delegates'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class CourseTableModel < Qt::AbstractTableModel

  def initialize(courses, parent)
    super()
    @courses = courses
    @view = parent
  end

  def refresh
    @courses = Course.all
    emit layoutChanged()
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
      course = @courses[index.row]
      case index.column
      when 0
        course.number = variant.toInt
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
    @courses.prepend(Course.new)
    emit layoutChanged()
  end

  def remove_current
    if @view.currentIndex.valid?
      @courses[@view.currentIndex.row].try(:destroy)
      @courses.delete_at(@view.currentIndex.row)
      emit layoutChanged()
      @view.currentIndex = createIndex(-1, -1)
    end
  end

end
