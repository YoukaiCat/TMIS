# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require './src/engine/models/subgroup'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SubgroupTableModel < Qt::AbstractTableModel

  def initialize(subgroups)
    super()
    @subgroups = subgroups
  end

  def rowCount(parent)
    @subgroups.size
  end

  def columnCount(parent)
    2
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    subgroup = @subgroups[index.row]
    return invalid if subgroup.nil?
    v = case index.column
        when 0
          subgroup.number
        when 1
          subgroup.group.title
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
          %w(Номер Группа)[section]
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
      subgroup = @subgroups[index.row]
      case index.column
      when 0
        subgroup.number = s.to_i
      when 1
        subgroup.group.name
      else
        raise "invalid column #{index.column}"
      end
      subgroup.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

end
