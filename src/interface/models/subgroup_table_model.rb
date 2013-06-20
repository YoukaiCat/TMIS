# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/subgroup'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SubgroupTableModel < Qt::AbstractTableModel

  def initialize(subgroups, parent)
    super()
    @subgroups = subgroups
    @view = parent
    @view.setItemDelegateForColumn(1, GroupComboBoxDelegate.new(self))
  end

  def rowCount(parent)
    @subgroups.size
  end

  def columnCount(parent)
    2
  end

  def data(index, role = Qt::DisplayRole)
    subgroup = @subgroups[index.row]
    default = Qt::Variant.new
    case role
    when Qt::DisplayRole
      case index.column
      when 0
        subgroup.number
      when 1
        subgroup.group.try(:title)
      else
        raise "invalid column #{index.column}"
      end.try(:to_v) || default
    when Qt::EditRole
      case index.column
      when 0
        subgroup.number
      when 1
        subgroup.group_id
      else
        raise "invalid column #{index.column}"
      end.try(:to_v) || default
    else
      default
    end
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
        subgroup.group_id = variant.toInt
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
      @subgroups[@view.currentIndex.row].try(:destroy)
      @subgroups.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@subgroups.size, 1))
    end
  end

end

class GroupComboBoxDelegate < Qt::ItemDelegate
  def initialize(parent)
    super
    @groups = Group.all.sort_by(&:title_for_sort)
  end

  def createEditor(parent, option, index)
    editor = Qt::ComboBox.new(parent)
    @groups.each{ |x| editor.addItem(x.title.to_s, x.id.to_v) }
    editor
  end

  def setEditorData(editor, index)
    value = index.model.data(index, Qt::EditRole)
    editor.setCurrentIndex(editor.findData(value))
  end

  def setModelData(editor, model, index)
    value = editor.itemData(editor.currentIndex)
    model.setData(index, value, Qt::EditRole)
  end

  def updateEditorGeometry(editor, option, index)
    editor.setGeometry(option.rect)
  end
end
