# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/study'
require_relative '../forms/edit_study'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class StudyTableModel < Qt::AbstractTableModel

  signals 'studySaved(QVariant)'

  def initialize(studies, date)
    super()
    @date = date
    @studies = studies
    @groups = studies.map{ |k, v| k }
    @titles = @groups.map(&:title)
  end

  def rowCount(parent = self)
    12
  end

  def columnCount(parent = self)
    @titles.size * 2
  end

  def data(index, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    study = @studies[index.row]
    return invalid if study.nil?
    begin
      if index.column.even?
        v = @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2].to_s
      else
        v = @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2].cabinet.title
      end
    rescue NoMethodError
      v = ''
    end
    Qt::Variant.new(v.to_s)
  end

  def headerData(section, orientation, role = Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole
    v = case orientation
        when Qt::Vertical
          (1..6).zip(Array.new(6, '')).flatten[section]
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
      if (studies = @studies[index.column / 2][1][(index.row / 2) + 1]) && (studies[index.row % 2])
        EditStudyDialog.new().setupData(studies[index.row % 2]).exec
      else
        p :test
        study = Study.new
        study.groupable_type = 'Group'
        study.groupable_id = @groups[index.column / 2].id
        study.number = (1..6).to_a[index.row / 2]
        study.date = @date
        EditStudyDialog.new().setupData(study).exec
        emit studySaved(study.id.to_v)
      end
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

end
