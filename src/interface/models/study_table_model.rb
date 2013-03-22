require './src/engine/models/study'

class StudyTableModel < Qt::AbstractTableModel

  def initialize(studies)
    super()
    @studies = studies
  end

  def rowCount(parent)
    @studies.size
  end

  def columnCount(parent)
    7
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    study = @studies[index.row]
    return invalid if study.nil?
    v = case index.column
        when 0
          study.subject.title
        when 1
          study.lecturer.to_s
        when 2
          study.cabinet.title
        when 3
          study.number.to_s
        when 4
          study.date.to_s
        when 5
          study.groupable.subgroup? ? study.groupable.group.title : study.groupable.title
        when 6
          study.groupable.subgroup? ? study.groupable.number : '--'
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
          %w(Subject Lecturer Cabinet Number Date Group Subgroup)[section]
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
      study = @studies[index.row]
      case index.column
      when 0
        study.subject_id = s.to_i
      when 1
        study.lecturer_id = s.to_i
      when 2
        study.cabinet_id = s.to_i
      when 3
        study.number = s.to_i
      when 4
        study.date = s
      when 5
        study.groupable.group.title = s
      when 6
        study.groupable.subgroup? ? study.groupable.number = s.to_i : '--'
      else
        raise "invalid column #{index.column}"
      end
      study.save
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

end
