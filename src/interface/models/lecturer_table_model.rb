# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/lecturer'
require_relative '../../engine/models/email'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class LecturerTableModel < Qt::AbstractTableModel

  def initialize(lecturers, parent)
    super()
    @lecturers = lecturers
    @view = parent
  end

  def rowCount(parent)
    @lecturers.size
  end

  def columnCount(parent)
    4
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    lecturer = @lecturers[index.row]
    return invalid if lecturer.nil?
    v = case index.column
        when 0
          lecturer.surname
        when 1
          lecturer.name
        when 2
          lecturer.patronymic
        when 3
          lecturer.emails.map(&:email).join(', ')
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
          %w(Фамилия Имя Отчество)[section]
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
      lecturer = @lecturers[index.row]
      case index.column
      when 0
        lecturer.surname = s.force_encoding('UTF-8')
      when 1
        lecturer.name = s.force_encoding('UTF-8')
      when 2
        lecturer.patronymic = s.force_encoding('UTF-8')
      when 3
        emails = s.force_encoding('UTF-8').split(/,\s*/)
        lecturer.emails.destroy_all
        emails.each do |email|
          lecturer.emails.create(email: email)
        end
      else
        raise "invalid column #{index.column}"
      end
      lecturer.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    beginInsertRows(createIndex(0, 0), 0, 0)
    @lecturers.prepend(Lecturer.new)
    emit dataChanged(createIndex(0, 0), createIndex(@lecturers.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @lecturers[@view.currentIndex.row].try(:destroy)
      @lecturers.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@lecturers.size, 1))
    end
  end

end
