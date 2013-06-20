# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/subject'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SubjectTableModel < Qt::AbstractTableModel

  def initialize(subjects, parent)
    super()
    @subjects = subjects
    @view = parent
  end

  def rowCount(parent)
    @subjects.size
  end

  def columnCount(parent)
    1
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    subject = @subjects[index.row]
    return invalid if subject.nil?
    v = case index.column
        when 0
          subject.title
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
          %w(Название)[section]
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
      subject = @subjects[index.row]
      case index.column
      when 0
        subject.title = variant.toString.force_encoding('UTF-8')
      else
        raise "invalid column #{index.column}"
      end
      subject.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    beginInsertRows(createIndex(0, 0), 0, 0)
    @subjects.prepend(Subject.new)
    emit dataChanged(createIndex(0, 0), createIndex(@subjects.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @subjects[@view.currentIndex.row].try(:destroy)
      @subjects.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@subjects.size, 1))
    end
  end

end
