# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/semester'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SemesterTableModel < Qt::AbstractTableModel

  def initialize(semesters, parent)
    super()
    @semesters = semesters
    @view = parent
    @CourseComboBoxDelegate = CourseComboBoxDelegate.new(self)
    @view.setItemDelegateForColumn(1, @CourseComboBoxDelegate)
  end

  def refresh
    @semesters = Semester.all
    @CourseComboBoxDelegate.setup
    emit layoutChanged()
  end

  def rowCount(parent)
    @semesters.size
  end

  def columnCount(parent)
    2
  end

  def data(index, role = Qt::DisplayRole)
    semester = @semesters[index.row]
    default = Qt::Variant.new
    case role
    when Qt::DisplayRole
      case index.column
      when 0
        semester.title
      when 1
        semester.course.try(:number)
      else
        raise "invalid column #{index.column}"
      end.try(:to_v) || default
    when Qt::EditRole
      case index.column
      when 0
        semester.title
      when 1
        semester.course_id
      else
        raise "invalid column #{index.column}"
      end.try(:to_v) || default
    else
      default
    end
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
      semester = @semesters[index.row]
      case index.column
      when 0
        semester.title = variant.toString.force_encoding('UTF-8')
      when 1
        semester.course_id = variant.toInt
      else
        raise "invalid column #{index.column}"
      end
      semester.save
      p semester
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    @semesters.prepend(Semester.new)
    emit layoutChanged()
  end

  def remove_current
    if @view.currentIndex.valid?
      @semesters[@view.currentIndex.row].try(:destroy)
      @semesters.delete_at(@view.currentIndex.row)
      emit layoutChanged()
    end
  end

end

class CourseComboBoxDelegate < Qt::ItemDelegate
  def initialize(parent)
    super
    setup
  end

  def setup
    @courses = Course.all.sort_by(&:number)
  end

  def createEditor(parent, option, index)
    editor = Qt::ComboBox.new(parent)
    @courses.each{ |x| editor.addItem(x.number.to_s, x.id.to_v) }
    editor
  end

  def setEditorData(editor, index)
    value = index.data
    editor.setCurrentIndex(editor.findData(value))
  end

  def setModelData(editor, model, index)
    value = editor.itemData(editor.currentIndex)
    model.setData(index, value, Qt::EditRole)
  end

  def updateEditorGeometry(editor, option, index)
    editor.setGeometry(option.rect)
  end
end
