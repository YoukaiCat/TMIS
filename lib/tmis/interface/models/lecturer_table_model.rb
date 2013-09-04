# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/lecturer'
require_relative '../../engine/models/email'
require 'tmis/interface/delegates'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class LecturerTableModel < Qt::AbstractTableModel

  def initialize(lecturers, parent)
    super()
    @lecturers = lecturers
    @view = parent
  end

  def refresh
    @lecturers = Lecturer.all
    emit layoutChanged()
  end

  def rowCount(parent)
    @lecturers.size
  end

  def columnCount(parent)
    5
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
        when 4
          lecturer.preferred_days
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
          ['Фамилия', 'Имя', 'Отчество', 'Email', 'Предпочитаемые дни'][section]
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
      lecturer = @lecturers[index.row]
      case index.column
      when 0
        lecturer.surname = variant.toString.force_encoding('UTF-8')
      when 1
        lecturer.name = variant.toString.force_encoding('UTF-8')
      when 2
        lecturer.patronymic = variant.toString.force_encoding('UTF-8')
      when 3
        emails = variant.toString.force_encoding('UTF-8').split(/,\s*/)
        lecturer.emails.destroy_all
        emails.each do |email|
          lecturer.emails.create(email: email)
        end
      when 4
        lecturer.preferred_days = variant.toString.force_encoding('UTF-8').split(/,\s*/).select{|x| x[/^[1-7]$/]}.uniq.join(', ')
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
    @lecturers.prepend(Lecturer.new)
    emit layoutChanged()
  end

  def remove_current
    if @view.currentIndex.valid?
      lecturer = @lecturers[@view.currentIndex.row]
      unless lecturer.stub
        lecturer.try(:destroy)
        @lecturers.delete_at(@view.currentIndex.row)
        emit layoutChanged()
        @view.currentIndex = createIndex(-1, -1)
      end
    end
  end

end
