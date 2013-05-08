# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/cabinet'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class CabinetTableModel < Qt::AbstractTableModel

  def initialize(cabinets)
    super()
    @cabinets = cabinets
  end

  def rowCount(parent)
    @cabinets.size
  end

  def columnCount(parent)
    1
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    cabinet = @cabinets[index.row]
    return invalid if cabinet.nil?
    v = case index.column
        when 0
          cabinet.title
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
          %w(Название)[section]
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
      cabinet = @cabinets[index.row]
      case index.column
      when 0
        cabinet.title = s
      else
        raise "invalid column #{index.column}"
      end
      cabinet.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

end
