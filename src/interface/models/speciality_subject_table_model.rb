# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/speciality_subject'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SpecialitySubjectTableModel < Qt::AbstractTableModel

  def initialize(speciality_subjects, parent)
    super()
    @speciality_subjects = speciality_subjects
    @view = parent
  end

  def rowCount(parent)
    @speciality_subjects.size
  end

  def columnCount(parent)
    4
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    speciality_subject = @speciality_subjects[index.row]
    return invalid if speciality_subject.nil?
    v = case index.column
        when 0
          speciality_subject.subject.title
        when 1
          speciality_subject.semester.number
        when 2
          speciality_subject.speciality.title
        when 3
          speciality_subject.hours
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
          %w(Название_предмета Номер_семестра Название_специальноси Часов)[section]
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
      speciality_subject = @speciality_subjects[index.row]
      case index.column
      when 0
        speciality_subject.subject.title
      when 1
        speciality_subject.semester.number
      when 2
        speciality_subject.speciality.title
      when 3
        speciality_subject.hours
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
    beginInsertRows(createIndex(0, 0), 0, 0)
    @speciality_subjects.prepend(SpecialitySubject.new)
    emit dataChanged(createIndex(0, 0), createIndex(@speciality_subjects.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @speciality_subjects[@view.currentIndex.row].try(:destroy)
      @speciality_subjects.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@speciality_subjects.size, 1))
    end
  end

end
