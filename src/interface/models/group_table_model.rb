# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/group'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class GroupTableModel < Qt::AbstractTableModel

  def initialize(groups, parent)
    super()
    @groups = groups
    @size = @groups.size
    @view = parent
    @SpecialityComboBoxDelegate = SpecialityComboBoxDelegate.new(self)
    @CourseComboBoxDelegate = CourseComboBoxDelegate.new(self)
    @view.setItemDelegateForColumn(1, @SpecialityComboBoxDelegate)
    @view.setItemDelegateForColumn(2, @CourseComboBoxDelegate)
  end

  def refresh
    @groups = Group.all
    @size = @groups.size
    @SpecialityComboBoxDelegate.setup
    @CourseComboBoxDelegate.setup
    emit layoutChanged()
  end

  def rowCount(parent)
    @size
  end

  def columnCount(parent)
    4
  end

  def data(index, role = Qt::DisplayRole)
    group = @groups[index.row]
    default = Qt::Variant.new
    case role
    when Qt::DisplayRole
      case index.column
      when 0
        group.title
      when 1
        group.speciality.try(:title)
      when 2
        group.course.try(:number)
      when 3
        group.emails.map(&:email).join(', ')
      else
        raise "invalid column #{index.column}"
      end.try(:to_v) || default
    when Qt::EditRole
      case index.column
      when 0
        group.title
      when 1
        group.speciality_id
      when 2
        group.course_id
      when 3
        group.emails.map(&:email).join(', ')
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
          %w(Название Специальность Курс Email)[section]
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
      group = @groups[index.row]
      case index.column
      when 0
        group.title = variant.toString.force_encoding('UTF-8')
      when 1
        group.speciality_id = variant.toInt
      when 2
        group.course_id = variant.toInt
      when 3
        emails = variant.toString.force_encoding('UTF-8').split(/,\s*/)
        group.emails.destroy_all
        emails.each do |email|
          group.emails.create(email: email)
        end
      else
        raise "invalid column #{index.column}"
      end
      group.save
      p group
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    @groups.prepend(Group.new)
    emit layoutChanged()
  end

  def remove_current
    if @view.currentIndex.valid?
      @groups[@view.currentIndex.row].try(:destroy)
      @groups.delete_at(@view.currentIndex.row)
      emit layoutChanged()
    end
  end

end

class SpecialityComboBoxDelegate < Qt::ItemDelegate
  def initialize(parent)
    super
    setup
  end

  def setup
    @specialities = Speciality.all.sort_by(&:title)
  end

  def createEditor(parent, option, index)
    editor = Qt::ComboBox.new(parent)
    @specialities.each{ |x| editor.addItem(x.title.to_s, x.id.to_v) }
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
