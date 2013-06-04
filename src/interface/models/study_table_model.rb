# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/study'
require_relative '../forms/edit_study'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class StudyTableModel < Qt::AbstractTableModel

  signals 'studySaved(QVariant)'
  slots 'editStudy(QModelIndex)'

  def initialize(date)
    super()
    @date = date
    @studies = get_studies
    @groups = Group.all.sort_by(&:title_for_sort)
    @titles = @groups.map(&:title)
    @color_at_index = {}
  end

  def get_studies
    Hash[ Group.all.map{ |g| [g, []] } ].
        merge(Study.of_groups_and_its_subgroups(Group.scoped).where(date: @date).group_by(&:get_group)).
        sort_by{ |k, v| k.title_for_sort }.map{ |k, v| [k, v.sort_by(&:number).group_by(&:number)] }
  end

  def refresh
    @studies = get_studies
  end

  def rowCount(parent = self)
    12
  end

  def columnCount(parent = self)
    @titles.size * 2
  end

  def data(index, role = Qt::DisplayRole, data = nil)
    invalid = Qt::Variant.new
    #return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    case role
    when Qt::DisplayRole || Qt::EditRole
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
    when  Qt::BackgroundRole #Qt::TextColorRole
      if @color_at_index[[index.row, index.column]]
        p :data
        p [index.row, index.column]
        Qt::Variant.new(@color_at_index[[index.row, index.column]])
      else
        Qt::Variant.new()
      end
    else
      invalid
    end
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
        study = studies[index.row % 2]
        EditStudyDialog.new().setupData(study).exec
        refresh
        emit studySaved(study.id.to_v)
      else
        study = Study.new
        study.groupable_type = 'Group'
        study.groupable_id = @groups[index.column / 2].id
        study.number = (1..6).to_a[index.row / 2]
        study.date = @date
        EditStudyDialog.new().setupData(study).exec
        refresh
        emit studySaved(study.id.to_v) unless study.new_record?
      end
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def setColor(group, number, color)
    p :color
    p number
    p group.title
    p (1..6).zip(7..7 + 6).flatten.index(number)
    p @groups.zip(Array.new(@groups.size, nil)).flatten.index(group)
    @color_at_index[[(1..6).zip(7..7 + 6).flatten.index(number), @groups.zip(Array.new(@groups.size, nil)).flatten.index(group)]] = color
    #@color_at_index[[@groups.zip(Array.new(@groups.size, nil)).index(group), number]] = color
  end

  def setColorCabinet(group, number, color)
    @color_at_index[[(1..6).zip(7..7 + 6).flatten.index(number), Array.new(@groups.size, nil).zip(@groups).flatten.index(group)]] = color
  end

  def editStudy(index)
    setData(index, nil, Qt::EditRole)
  end
end
