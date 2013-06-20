# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/semester'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SemesterTableModel < Qt::AbstractTableModel

  def initialize(semesters, parent)
    super()
    @semesters = semesters
    @view = parent
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
        semester.title = s
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

  def insert_new
    beginInsertRows(createIndex(0, 0), 0, 0)
    @semesters.prepend(Semester.new)
    emit dataChanged(createIndex(0, 0), createIndex(@semesters.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @semesters[@view.currentIndex.row].try(:destroy)
      @semesters.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@semesters.size, 1))
    end
  end

end
