# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/speciality_subject'
require 'tmis/interface/delegates'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SpecialitySubjectTableModel < Qt::AbstractTableModel

  def initialize(speciality_subjects, parent)
    super()
    @speciality_subjects = speciality_subjects
    @view = parent
    @lecturerComboBoxDelegate = ARComboBoxDelegate.new(self, Lecturer, :surname)
    @subjectComboBoxDelegate = ARComboBoxDelegate.new(self, Subject, :title)
    @semesterComboBoxDelegate = ARComboBoxDelegate.new(self, Semester, :title)
    @specialityComboBoxDelegate = ARComboBoxDelegate.new(self, Speciality, :title)
    @facultativeRadioButtonDelegate = RadioButtonDelegate.new(self)
    @view.setItemDelegateForColumn(0, @lecturerComboBoxDelegate)
    @view.setItemDelegateForColumn(1, @subjectComboBoxDelegate)
    @view.setItemDelegateForColumn(2, @semesterComboBoxDelegate)
    @view.setItemDelegateForColumn(3, @specialityComboBoxDelegate)
    @view.setItemDelegateForColumn(9, @facultativeRadioButtonDelegate)
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
    10
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
        [speciality_subject.lecture_hours,
         speciality_subject.practical_hours,
         speciality_subject.consultations_hours ].
        keep_if{|x| x.respond_to?(:+) }.inject(:+)
      when 8
        speciality_subject.preffered_days
      when 9
        speciality_subject.facultative
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
        [speciality_subject.lecture_hours,
         speciality_subject.practical_hours,
         speciality_subject.consultations_hours ].
        keep_if{|x| x.respond_to?(:+) }.inject(:+)
      when 8
        speciality_subject.preffered_days
      when 9
        speciality_subject.facultative
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
          ['Преподаватель', 'Предмет', 'Семестр', 'Специальность', 'Лекционные часы', 'Практические часы', 'Консультации', 'Всего', 'Рекомендуемые дни', 'Факультатив'][section]
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
        speciality_subject.preffered_days = variant.toString.force_encoding('UTF-8').split(/,\s*/).select{|x| x[/^[1-7]$/]}.uniq.join(', ')
      when 9
        speciality_subject.facultative = variant.toBool
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
      @view.currentIndex = createIndex(-1, -1)
    end
  end

end
