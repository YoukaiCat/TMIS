# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/study'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class StudyTableModel < Qt::AbstractTableModel

  def initialize(studies)
    super()
    @studies = studies
    @titles = studies.map{ |g, v| g.title }
    p @titles.size
  end

  def rowCount(parent)
    6
  end

  def columnCount(parent)
    @titles.size * 2
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    study = @studies[index.row]
    return invalid if study.nil?
    begin
      if index.column.even?
        #p "#{index.column} | #{index.column / 2}"
        v = @studies[index.column / 2][1][index.row][1].map(&:to_s).join("\n") || ''
      else
        v = @studies[index.column / 2][1][index.row][1].map{ |s| s.cabinet.title }.join("\n") || ''
      end
    rescue
      v = ''
    end
    Qt::Variant.new(v.to_s)
  end

  def headerData(section, orientation, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole
    v = case orientation
        when Qt::Vertical
          (1..6).to_a[section]
        when Qt::Horizontal
          @titles.zip(Array.new(@titles.size, 'Кабинет')).flatten[section]
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
