# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/cabinet'
require 'tmis/interface/delegates'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class CabinetTableModel < Qt::AbstractTableModel

  def initialize(cabinets, parent)
    super()
    @cabinets = cabinets
    @view = parent
    @view.setItemDelegateForColumn(1, RadioButtonDelegate.new(self))
  end

  def refresh
    @cabinets = Cabinet.all
    emit layoutChanged()
  end

  def rowCount(parent)
    @cabinets.size
  end

  def columnCount(parent)
    2
  end

  def data(index, role = Qt::DisplayRole)
    cabinet = @cabinets[index.row]
    default = Qt::Variant.new
    case role
    when Qt::DisplayRole
      case index.column
      when 0
        cabinet.title.to_v
      when 1
        cabinet.with_computers.to_s.to_v
      else
        raise "invalid column #{index.column}"
      end
    when Qt::EditRole
      case index.column
      when 0
        cabinet.title.to_v
      when 1
        cabinet.with_computers.to_v
      else
        raise "invalid column #{index.column}"
      end
    else
      default
    end
  end

  def headerData(section, orientation, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole
    v = case orientation
        when Qt::Horizontal
          %w(Название Компьютерный)[section]
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
      cabinet = @cabinets[index.row]
      case index.column
      when 0
        cabinet.title = variant.toString.force_encoding('UTF-8')
      when 1
        cabinet.with_computers = variant.toBool
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

  def insert_new
    @cabinets.prepend(Cabinet.new)
    emit layoutChanged()
  end

  def remove_current
    if @view.currentIndex.valid?
      cabinet = @cabinets[@view.currentIndex.row]
      unless cabinet.stub
        cabinet.try(:destroy)
        @cabinets.delete_at(@view.currentIndex.row)
        emit layoutChanged()
        @view.currentIndex = createIndex(-1, -1)
      end
    end
  end

end
