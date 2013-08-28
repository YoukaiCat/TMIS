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

  def refresh
    @subjects = Subject.all
    emit layoutChanged()
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
    @subjects.prepend(Subject.new)
    emit layoutChanged()
  end

  def remove_current
    if @view.currentIndex.valid?
      subject = @subjects[@view.currentIndex.row]
      unless subject.stub
        subject.try(:destroy)
        @subjects.delete_at(@view.currentIndex.row)
        emit layoutChanged()
        @view.currentIndex = createIndex(-1, -1)
      end
    end
  end

end
