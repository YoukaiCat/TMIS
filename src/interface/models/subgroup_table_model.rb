# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/subgroup'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SubgroupTableModel < Qt::AbstractTableModel

  def initialize(subgroups, parent)
    super()
    @subgroups = subgroups
    @view = parent
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
      subgroup = @subgroups[index.row]
      case index.column
      when 0
        subgroup.number = variant.toInt
      when 1
        subgroup.group.name = variant.toString
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

  def insert_new
    beginInsertRows(createIndex(0, 0), 0, 0)
    @subgroups.prepend(Subgroup.new)
    emit dataChanged(createIndex(0, 0), createIndex(@subgroups.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @subgroups[@view.currentIndex.row].try(:delete)
      @subgroups.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@subgroups.size, 1))
    end
  end

end
