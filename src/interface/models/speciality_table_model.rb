# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/speciality'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class SpecialityTableModel < Qt::AbstractTableModel

  def initialize(specialities, parent)
    super()
    @specialities = specialities
    @view = parent
  end

  def rowCount(parent)
    @specialities.size
  end

  def columnCount(parent)
    1
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    speciality = @specialities[index.row]
    return invalid if speciality.nil?
    v = case index.column
        when 0
          speciality.title
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
      speciality = @specialities[index.row]
      case index.column
      when 0
        speciality.title = s
      else
        raise "invalid column #{index.column}"
      end
      speciality.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def insert_new
    beginInsertRows(createIndex(0, 0), 0, 0)
    @specialities.prepend(Speciality.new)
    emit dataChanged(createIndex(0, 0), createIndex(@specialities.size, 1))
    endInsertRows
  end

  def remove_current
    if @view.currentIndex.valid?
      beginRemoveRows(createIndex(@view.currentIndex.row - 1, @view.currentIndex.column - 1), @view.currentIndex.row, @view.currentIndex.row)
      @specialities[@view.currentIndex.row].try(:delete)
      @specialities.delete_at(@view.currentIndex.row)
      endRemoveRows
      emit dataChanged(createIndex(0, 0), createIndex(@specialities.size, 1))
    end
  end

end
