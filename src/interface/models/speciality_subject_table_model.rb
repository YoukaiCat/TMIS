# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/speciality_subject'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SpecialitySubjectTableModel < Qt::AbstractTableModel

  def initialize(speciality_subjects, parent)
    super()
    @speciality_subjects = speciality_subjects
    @view = parent
    @lecturerComboBoxDelegate = LecturerComboBoxDelegate.new(self)
    @subjectComboBoxDelegate = SubjectComboBoxDelegate.new(self)
    @semesterComboBoxDelegate = SemesterComboBoxDelegate.new(self)
    @specialityComboBoxDelegate = SpecialityComboBoxDelegate.new(self)
    @view.setItemDelegateForColumn(0, @lecturerComboBoxDelegate)
    @view.setItemDelegateForColumn(1, @subjectComboBoxDelegate)
    @view.setItemDelegateForColumn(2, @semesterComboBoxDelegate)
    @view.setItemDelegateForColumn(3, @specialityComboBoxDelegate)
  end

  def refresh
    @speciality_subjects = SpecialitySubject.all
    @lecturerComboBoxDelegate.setup
    @subjectComboBoxDelegate.setup
    @semesterComboBoxDelegate.setup
    @specialityComboBoxDelegate.setup
    emit layoutChanged()
  end

  def rowCount(parent)
    @speciality_subjects.size
  end

  def columnCount(parent)
    9
  end

  def data(index, role = Qt::DisplayRole)
    speciality_subject = @speciality_subjects[index.row]
    default = Qt::Variant.new
    case role
    when Qt::DisplayRole
      case index.column
      when 0
        speciality_subject.lecturer.try(:to_s)
      when 1
        speciality_subject.subject.try(:title)
      when 2
        speciality_subject.semester.try(:title)
      when 3
        speciality_subject.speciality.try(:title)
      when 4
        speciality_subject.lecture_hours
      when 5
        speciality_subject.practical_hours
      when 6
        speciality_subject.consultations_hours
      when 7
        speciality_subject.lecture_hours.try(:+, speciality_subject.practical_hours).try(:+, speciality_subject.consultations_hours)
      when 8
        speciality_subject.preffered_days
      else
        raise "invalid column #{index.column}"
      end.try(:to_v) || default
    when Qt::EditRole
      case index.column
      when 0
        speciality_subject.lecturer_id
      when 1
        speciality_subject.subject_id
      when 2
        speciality_subject.semester_id
      when 3
        speciality_subject.speciality_id
      when 4
        speciality_subject.lecture_hours
      when 5
        speciality_subject.practical_hours
      when 6
        speciality_subject.consultations_hours
      when 7
        speciality_subject.lecture_hours.try(:+, speciality_subject.practical_hours).try(:+, speciality_subject.consultations_hours)
      when 8
        speciality_subject.preffered_days
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
          ['Преподаватель', 'Предмет', 'Семестр', 'Специальность', 'Лекционные часы', 'Практические часы', 'Консультации', 'Всего', 'Рекомендуемый день'][section]
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
      speciality_subject = @speciality_subjects[index.row]
      case index.column
      when 0
        speciality_subject.lecturer_id = variant.toInt
      when 1
        speciality_subject.subject_id = variant.toInt
      when 2
        speciality_subject.semester_id = variant.toInt
      when 3
        speciality_subject.speciality_id = variant.toInt
      when 4
        speciality_subject.lecture_hours = variant.toInt
      when 5
        speciality_subject.practical_hours = variant.toInt
      when 6
        speciality_subject.consultations_hours = variant.toInt
      when 7
        true
      when 8
        speciality_subject.preffered_days = variant.toString
      else
        raise "invalid column #{index.column}"
      end
      speciality_subject.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    @speciality_subjects.prepend(SpecialitySubject.new)
    emit layoutChanged()
  end

  def remove_current
    if @view.currentIndex.valid?
      @speciality_subjects[@view.currentIndex.row].try(:destroy)
      @speciality_subjects.delete_at(@view.currentIndex.row)
      emit layoutChanged()
    end
  end

end

class LecturerComboBoxDelegate < Qt::ItemDelegate
  def initialize(parent)
    super
    setup
  end

  def setup
    @lecturers = Lecturer.all.sort_by(&:surname)
  end

  def createEditor(parent, option, index)
    editor = Qt::ComboBox.new(parent)
    @lecturers.each{ |x| editor.addItem(x.surname.to_s, x.id.to_v) }
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

class SubjectComboBoxDelegate < Qt::ItemDelegate
  def initialize(parent)
    super
    setup
  end

  def setup
    @subjects = Subject.all.sort_by(&:title)
  end

  def createEditor(parent, option, index)
    editor = Qt::ComboBox.new(parent)
    @subjects.each{ |x| editor.addItem(x.title.to_s, x.id.to_v) }
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

class SemesterComboBoxDelegate < Qt::ItemDelegate
  def initialize(parent)
    super
    setup
  end

  def setup
    @semesters = Semester.all.sort_by(&:title)
  end

  def createEditor(parent, option, index)
    editor = Qt::ComboBox.new(parent)
    @semesters.each{ |x| editor.addItem(x.title.to_s, x.id.to_v) }
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
