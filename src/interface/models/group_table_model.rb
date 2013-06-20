# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/group'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class GroupTableModel < Qt::AbstractTableModel

  def initialize(groups, parent)
    super()
    @groups = groups
    @view = parent
  end

  def rowCount(parent)
    @groups.size
  end

  def columnCount(parent)
    4
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    group = @groups[index.row]
    return invalid if group.nil?
    v = case index.column
        when 0
          group.title
        when 1
          group.speciality ? group.speciality.title : group.speciality_id
        when 2
          group.course ?  group.course.number :  group.course_id
        when 3
          group.emails.map(&:email).join(', ')
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
          %w(Название Специальность Курс)[section]
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
      group = @groups[index.row]
      case index.column
      when 0
        group.title.force_encoding('UTF-8')
      when 1
        group.speciality_id
      when 2
        group.course_id
      when 3
        emails = s.force_encoding('UTF-8').split(/,\s*/)
        group.emails.destroy_all
        emails.each do |email|
          group.emails.create(email: email)
        end
      else
        raise "invalid column #{index.column}"
      end
      group.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    beginInsertRows(createIndex(0, 0), 0, 0)
    @groups.prepend(Group.new)
    emit dataChanged(createIndex(0, 0), createIndex(@groups.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @groups[@view.currentIndex.row].try(:destroy)
      @groups.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@groups.size, 1))
    end
  end

end
