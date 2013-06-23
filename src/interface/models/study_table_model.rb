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
    @studies = setup
    @colors_for_studies = {}
    @colors_for_cabinets = {}
  end

  def setup
    @groups = Group.all.sort_by(&:title_for_sort)
    @titles = @groups.map(&:title)
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
    @studies = setup
    emit layoutChanged()
  end

  def rowCount(parent = self)
    12
  end

  def columnCount(parent = self)
    @titles.size * 2
  end

  def data(index, role = Qt::DisplayRole, data = nil)
    default = Qt::Variant.new
    return default unless index.valid?
    case role
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
      #if index.column.even?
      #  @studies[index.column / 2].try(:at, 1).try(:fetch, (index.row / 2) + 1, nil).try(:at, index.row % 2).try(:to_s)
      #else
      #  @studies[index.column / 2].try(:at, 1).try(:fetch, (index.row / 2) + 1, nil).try(:at, index.row % 2).try(:cabinet).try(:title)
      #end.try(:to_v) || default
    when Qt::UserRole
      begin
        if (study = @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2])
          Base64.encode64(Marshal.dump(study)).to_v
        elsif (group = @studies[index.column / 2][0])
          Base64.encode64(Marshal.dump(group)).to_v
        else
          default
        end
      rescue NoMethodError
        default
      end
    when  Qt::BackgroundRole #Qt::TextColorRole
      begin
        if index.column.even?
          study = @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2]
          if @colors_for_studies[study.id]
            @colors_for_studies[study.id].to_v
          elsif study.color
            Qt::Variant.fromValue(Qt::Color.new(study.color))
          else
            default
          end
        else
          study = @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2]
          if @colors_for_cabinets[study.id]
            @colors_for_cabinets[study.id].to_v
          elsif study.color
            Qt::Variant.fromValue(Qt::Color.new(study.color))
          else
            default
          end
        end
      rescue NoMethodError
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
    Qt::ItemIsDragEnabled | Qt::ItemIsDropEnabled | super(index) if index.valid?
  end

  def setData(index, variant, role = Qt::EditRole)
    if index.valid? and role == Qt::EditRole
      if (studies = @studies[index.column / 2][1][(index.row / 2) + 1]) && (studies[index.row % 2])
        study = studies[index.row % 2]
        EditStudyDialog.new().setupData(study).exec
        refresh
        emit studySaved(study.date.to_v) unless study.date == @date
      else
        study = Study.new
        study.groupable_type = 'Group'
        study.groupable_id = @groups[index.column / 2].id
        study.number = (1..6).to_a[index.row / 2]
        study.date = @date
        EditStudyDialog.new().setupData(study).exec
        unless study.new_record?
          refresh
          emit studySaved(study.date.to_v) unless study.date == @date
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

  #def dropEvent(event)
    #if event.mimeData().hasFormat("text/plain")
    #  event.accept()
    #else
    #  event.ignore()
    #end
  #end

  def mimeData(indexes)
    index = indexes.first
    mime_data = super indexes # для обхода ошибки сегментации Qt::MimeData создаётся с помощью родительского метода
    if (studies = @studies[index.column / 2][1][(index.row / 2) + 1]) && (studies[index.row % 2])
      study = studies[index.row % 2]
      study_dump = Base64.encode64(Marshal.dump(study))
      byte_study = Qt::ByteArray.new study_dump
      table_model_ref = Qt::ByteArray.new self.object_id.to_s
      mime_data.setData('application/study', byte_study)
      mime_data.setData('application/model', table_model_ref)
    else
      mime_data.setData('application/empty', Qt::ByteArray.new(''))
    end
    mime_data
  end

  def dropMimeData(data, action, row, column, index)
    table_model = ObjectSpace._id2ref(data.data('application/model').data.to_i)
    subject_id = data.data('application/subject').data if data.hasFormat('application/subject')
    lecturer_id = data.data('application/lecturer').data if data.hasFormat('application/lecturer')
    cabinet_id = data.data('application/cabinet').data if data.hasFormat('application/cabinet')
    # date почему-то содержит "application/subject" с какимто мусором если drag осуществляется из табицы
    return false if !index.valid? || data.hasFormat('application/empty')
    if data.hasFormat('application/study')
      study = Marshal.load(Base64.decode64(data.data('application/study').data))
      study.number = (1..6).to_a[index.row / 2]
      study.date = @date
      if study.groupable.group?
        study.groupable_id = @groups[index.column / 2].id
      else
        number = study.groupable.number
        study.groupable = @groups[index.column / 2].subgroups.where(number: number).first
      end
      if (studies = @studies[index.column / 2][1][(index.row / 2) + 1]) && (studies[index.row % 2])
        exist_study = studies[index.row % 2]
        exist_study.delete unless exist_study == study
        @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2] = study
      else
        if @studies[index.column / 2][1][(index.row / 2) + 1]
          @studies[index.column / 2][1][(index.row / 2) + 1][index.row % 2] = study
        else
          array = []
          array[index.row % 2] = study
          @studies[index.column / 2][1][(index.row / 2) + 1] = array
        end
      end
    else
      if (studies = @studies[index.column / 2][1][(index.row / 2) + 1]) && (studies[index.row % 2])
        study = studies[index.row % 2]
        study.subject_id = subject_id if subject_id
        study.lecturer_id = lecturer_id if lecturer_id
        study.cabinet_id = cabinet_id if cabinet_id
      elsif subject_id || lecturer_id || cabinet_id
        study = Study.new
        if (studies = @studies[index.column / 2][1][(index.row / 2) + 1]) && (studies[(index.row % 2) - 1])
          another_study = studies[(index.row % 2) - 1]
          if another_study.groupable.subgroup?
            if another_study.groupable.number == 1
              study.groupable = another_study.groupable.get_group.subgroups.where(number: 2).first
            else
              study.groupable = another_study.groupable.get_group.subgroups.where(number: 1).first
            end
          else
            another_study.groupable = another_study.groupable.get_group.subgroups.where(number: 1).first
            study.groupable = another_study.groupable.get_group.subgroups.where(number: 2).first
          end
        else
          study.groupable_type = 'Group'
          study.groupable_id = @groups[index.column / 2].id
        end
        study.number = (1..6).to_a[index.row / 2]
        study.date = @date
        study.subject_id = subject_id || Subject.where(stub: true).first.id
        study.lecturer_id = lecturer_id || Lecturer.where(stub: true).first.id
        study.cabinet_id = cabinet_id || Cabinet.where(stub: true).first.id
      end
    end
    study.save
    refresh
    table_model.refresh if table_model && table_model != self
    emit dataChanged(index, index)
    true
  end

  def setItemData(index, roles)
    false
  end

  def supportedDropActions
    Qt::CopyAction
  end

  def insertRows(row, count, parent )
    false
  end

  def insertColumns(column, count, parent )
    false
  end

  def mimeTypes
    ['application/subject', 'application/lecturer', 'application/cabinet', 'application/study']
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
    refresh
  end

  def editStudy(index)
    setData(index, nil, Qt::EditRole)
  end
end
