# encoding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../engine/models/study'
require_relative '../forms/edit_study'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class StudyTableModel < Qt::AbstractTableModel

  signals 'studySaved(QVariant)'
  slots 'editStudy(QModelIndex)'
  slots 'removeData()'
  slots 'displayMenu(QPoint)'
  slots 'cancelColoring()'

  def initialize(date, parent = nil)
    super()
    @view = parent
    @date = date
    @studies = get_studies
    @groups = Group.all.sort_by(&:title_for_sort)
    @titles = @groups.map(&:title)
    @colors_for_studies = {}
    @colors_for_cabinets = {}
  end

  def get_studies
    Hash[ Group.all.map{|g| [g, []]} ].
      merge(Study.of_groups_and_its_subgroups(Group.scoped).
      where(date: @date).
      group_by(&:get_group)).
      sort_by{|k, v| k.title_for_sort}.
      map do |k, v|
        [k, Hash[ v.sort_by(&:number).
                    group_by(&:number).
                    map{|n, ss| [n, ss.sort_by{|s| s.groupable.number}]}
                ] ]
      end
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
    default = Qt::Variant.new
    #return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    case role
    #when Qt::UserRole # for future use
    when Qt::DisplayRole || Qt::EditRole
      begin
        if index.column.even?
          @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2].to_s.to_v
        else
          @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2].cabinet.title.to_v
        end
      rescue NoMethodError
        default
      end
    when  Qt::BackgroundRole #Qt::TextColorRole
      begin
        if index.column.even?
          @colors_for_studies[@studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2].id].to_v
        else
          @colors_for_cabinets[@studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2].id].to_v
        end
      rescue
        default
      end
    else
      default
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
        emit studySaved(study.id.to_v) unless study.date == @date
      else
        study = Study.new
        study.groupable_type = 'Group'
        study.groupable_id = @groups[index.column / 2].id
        study.number = (1..6).to_a[index.row / 2]
        study.date = @date
        EditStudyDialog.new().setupData(study).exec
        unless study.new_record?
          refresh
          emit studySaved(study.id.to_v) unless study.date == @date
        end
      end
      emit dataChanged(index, index)
      true
    else
      false
    end
  end

  def removeData
    if @view.hasFocus && (index = @view.currentIndex).valid?
      if (studies = @studies[index.column / 2][1][(index.row / 2) + 1])
        if (study = studies[index.row % 2])
          study.delete
          refresh
          emit dataChanged(index, createIndex(index.row, index.column + 1))
        end
      end
    end
  end

  def displayMenu(pos)
    menu = Qt::Menu.new()
    remove = Qt::Action.new('Удалить', menu)
    connect(remove, SIGNAL('triggered()'), self, SLOT('removeData()'))
    menu.addAction(remove)
    menu.exec(@view.viewport.mapToGlobal(pos))
  end

  def setColor(id, color)
    @colors_for_studies[id] = color
  end

  def setColorCabinet(id, color)
    @colors_for_cabinets[id] = color
  end

  def cancelColoring()
    @colors_for_studies.clear
    @colors_for_cabinets.clear
  end

  def editStudy(index)
    setData(index, nil, Qt::EditRole)
  end
end
