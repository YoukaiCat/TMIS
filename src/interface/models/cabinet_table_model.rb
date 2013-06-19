# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/cabinet'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class CabinetTableModel < Qt::AbstractTableModel

  def initialize(cabinets, parent)
    super()
    @cabinets = cabinets
    @view = parent
    @view.setItemDelegateForColumn(1, RadioButtonDelegate.new(self))
  end

  def rowCount(parent)
    @cabinets.size
  end

  def columnCount(parent)
    2
  end

  def data(index, role = Qt::DisplayRole)
    #invalid = Qt::Variant.new
    #return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    #cabinet = @cabinets[index.row]
    #return invalid if cabinet.nil?
    #v = case index.column
    #    when 0
    #      cabinet.title
    #    when 1
    #      cabinet.with_computers
    #    else
    #      raise "invalid column #{index.column}"
    #    end || ''
    #Qt::Variant.new(v)
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
        cabinet.title = variant.value.force_encoding('UTF-8')
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
    beginInsertRows(createIndex(0, 0), 0, 0)
    @cabinets.prepend(Cabinet.new)
    emit dataChanged(createIndex(0, 0), createIndex(@cabinets.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @cabinets[@view.currentIndex.row].try(:delete)
      @cabinets.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@cabinets.size, 1))
    end
  end

end

class RadioButtonDelegate < Qt::ItemDelegate

  def initialize(parent)
    super
  end

  def createEditor(parent, option, index)
    Qt::CheckBox.new(parent)
  end

  def setEditorData(editor, index)
    value = index.data.toBool #index.model.data(index, Qt::EditRole)
    button = editor
    button.checked = value # button.setValue(value)
  end

  def setModelData(editor, model, index)
    button = editor
    value = button.isChecked # button.value
    model.setData(index, value.to_v, Qt::EditRole)
  end

  def updateEditorGeometry(editor, option, index)
    editor.setGeometry(option.rect)
  end
end
