# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/group'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class GroupTableModel < Qt::AbstractTableModel

  def initialize(groups)
    super()
    @groups = groups
  end

  def rowCount(parent)
    @groups.size
  end

  def columnCount(parent)
    3
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
        group.title
      when 1
        group.speciality_id
      when 2
        group.course_id
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

end
