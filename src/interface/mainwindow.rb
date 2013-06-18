# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Copyright (C) 2013 Vladislav Mileshkin
#
# This file is part of TMIS.
#
# TMIS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# TMIS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with TMIS. If not, see <http://www.gnu.org/licenses/>.
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'mail'
require 'tmpdir'
require 'fileutils'
require 'contracts'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../engine/database'
require_relative '../engine/verificator'
require_relative '../engine/import/timetable_manager'
require_relative '../engine/import/timetable_reader'
require_relative '../engine/import/spreadsheet_roo'
require_relative '../engine/export/timetable_exporter.rb'
require_relative '../engine/mailer/mailer'
require_relative '../engine/models/cabinet'
require_relative '../engine/models/course'
require_relative '../engine/models/group'
require_relative '../engine/models/lecturer'
require_relative '../engine/models/semester'
require_relative '../engine/models/speciality'
require_relative '../engine/models/speciality_subject'
require_relative '../engine/models/study'
require_relative '../engine/models/subject'
require_relative '../engine/models/subgroup'
require_relative 'ui_mainwindow'
require_relative 'forms/about'
require_relative 'forms/settings'
require_relative 'forms/import'
require_relative 'forms/console'
require_relative 'forms/export_general_timetable'
require_relative 'forms/export_lecturer_timetable'
require_relative 'forms/export_group_timetable'
require_relative 'models/cabinet_table_model'
require_relative 'models/course_table_model'
require_relative 'models/group_table_model'
require_relative 'models/lecturer_table_model'
require_relative 'models/semester_table_model'
require_relative 'models/speciality_table_model'
require_relative 'models/speciality_subject_table_model'
require_relative 'models/study_table_model'
require_relative 'models/subject_table_model'
require_relative 'models/subgroup_table_model'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
#class Object
#  def to_v
#    Qt::Variant.new object_id
#  end
#end
#
#class Qt::Variant
#  def to_o
#    ObjectSpace._id2ref to_int
#  end
#end

class Object
  def to_v
    Qt::Variant.new(self)
  end
end

class MainWindow < Qt::MainWindow

  # File menu
  slots 'on_newAction_triggered()'
  slots 'on_openAction_triggered()'
  slots 'on_saveAction_triggered()'
  slots 'on_saveAsAction_triggered()'
  slots 'on_importAction_triggered()'
  slots 'on_closeAction_triggered()'
  slots 'on_quitAction_triggered()'
  # Tools menu
  slots 'on_verifyLecturersAction_triggered()'
  slots 'on_verifyCabinetsAction_triggered()'
  slots 'on_showLecturerStubsAction_triggered()'
  slots 'on_showCabinetStubsAction_triggered()'
  slots 'on_showSubjectsStubsAction_triggered()'
  # Main
  slots 'on_dateDateEdit_dateChanged()'
  # Self
  slots 'open_file()'
  slots 'clear_recent_files()'
  # help
  slots 'on_showManualAction_triggered()'

  def initialize(parent = nil)
    super(parent)
    @ui = Ui::MainWindow.new
    @ui.setup_ui self
    @ui.exportMenu.enabled = false
    @study_table_views = [@ui.studiesTableView, @ui.studiesTableView2, @ui.studiesTableView3,
                          @ui.studiesTableView4, @ui.studiesTableView5, @ui.studiesTableView6]
    @table_views = [[Cabinet, CabinetTableModel, @ui.cabinetsTableView], [Course, CourseTableModel, @ui.coursesTableView],
                    [Group, GroupTableModel, @ui.groupsTableView], [Lecturer, LecturerTableModel, @ui.lecturersTableView],
                    [Semester, SemesterTableModel, @ui.semestersTableView], [Speciality, SpecialityTableModel, @ui.specialitiesTableView],
                    [SpecialitySubject, SpecialitySubjectTableModel, @ui.specialitySubjectsTableView],
                    [Subgroup, SubgroupTableModel, @ui.subgroupsTableView], [Subject, SubjectTableModel, @ui.subjectsTableView]]
    # Следующие два атрибута используются для обхода бага связанного с работой GC
    # http://stackoverflow.com/questions/9715548/cant-display-more-than-one-table-model-inheriting-from-the-same-class-on-differ
    @table_models = @study_table_models = []
    @tables_views_to_hide = @study_table_views + [@ui.cabinetsTableView, @ui.coursesTableView, @ui.groupsTableView,
                     @ui.lecturersTableView, @ui.semestersTableView, @ui.specialitySubjectsTableView,
                     @ui.specialitiesTableView, @ui.subgroupsTableView, @ui.subjectsTableView, @ui.dateDateEdit,
                     @ui.dayLabel, @ui.dayLabel2, @ui.dayLabel3, @ui.dayLabel4, @ui.dayLabel5, @ui.dayLabel6]
    @widgets_to_disable = [@ui.exportMenu, @ui.verifyMenu, @ui.saveAsAction]
    @tables_views_to_hide.each &:hide
    @widgets_to_disable.each{ |x| x.enabled = false }
    modeActionGroup = Qt::ActionGroup.new(self)
    modeActionGroup.setExclusive(true)
    modeActionGroup.addAction(@ui.weeklyViewAction)
    modeActionGroup.addAction(@ui.dailyViewAction)
    @temp = ->(){ "#{Dir.mktmpdir('tmis')}/temp.sqlite" }
    connect(@ui.aboutQtAction, SIGNAL('triggered()')){ Qt::Application.aboutQt }
    connect(@ui.aboutProgramAction, SIGNAL('triggered()')){ AboutDialog.new.exec }
    connect(@ui.exportGeneralAction, SIGNAL('triggered()')){ ExportGeneralTimetableDialog.new.exec }
    connect(@ui.exportForLecturersAction, SIGNAL('triggered()')){ ExportLecturerTimetableDialog.new.exec }
    connect(@ui.exportForGroupsAction, SIGNAL('triggered()')){ ExportGroupTimetableDialog.new.exec }
    connect(@ui.settingsAction, SIGNAL('triggered()')){ SettingsDialog.new.exec }
    @clear_recent_action = Qt::Action.new('Очистить', self)
    @clear_recent_action.setData Qt::Variant.new('clear')
    connect(@clear_recent_action, SIGNAL('triggered()'), self, SLOT('clear_recent_files()'))
    @ui.dateDateEdit.setDate(Qt::Date.fromString(Date.today.to_s, Qt::ISODate))
    setup_dateEdit(Date.today)
    @ui.recentMenu.clear
    @ui.recentMenu.addActions([@clear_recent_action] + Settings[:recent, :files].split.map{ |path| create_recent_action(path) })
    #Settings[:app, :first_run] = ''
    Settings.set_defaults_if_first_run
  end

  def on_newAction_triggered
    Database.instance.connect_to(@temp.())
    create_stubs
    show_tables
  end

  def create_stubs
    Lecturer.create(surname: Settings[:stubs, :lecturer], stub: true)
    Cabinet.create(title: Settings[:stubs, :cabinet], stub: true)
    Subject.create(title: Settings[:stubs, :subject], stub: true)
  end

  def on_openAction_triggered
    if (filename = Qt::FileDialog::getOpenFileName(self, 'Open File', '', 'TMIS databases (SQLite3)(*.sqlite)'))
      Database.instance.connect_to filename
      update_recent filename
      show_tables
    end
  end

  def on_saveAction_triggered
  end

  def on_saveAsAction_triggered
    if (filename = Qt::FileDialog::getSaveFileName(self, 'Save File', 'NewTimetable.sqlite', 'TMIS databases (SQLite3)(*.sqlite)'))
      filename.force_encoding('UTF-8')
      FileUtils.cp(Database.instance.path, filename) unless Database.instance.path == filename
      Database.instance.connect_to filename
      update_recent filename
      show_tables
    end
  end

  def on_importAction_triggered
    please_wait do
      if (filename = Qt::FileDialog::getOpenFileName(self, 'Open File', '', 'Spreadsheets(*.xls *.xlsx *.ods *.csv)'))
        (id = ImportDialog.new).exec
        unless id.params.empty?
          sheet = SpreadsheetCreater.create filename
          reader = TimetableReader.new(sheet, id.params[:sheet])
          Database.instance.connect_to(@temp.())
          create_stubs
          TimetableManager.new(reader, id.params[:date]).save_to_db
          show_tables
        end
      end
    end
  end

  def on_closeAction_triggered
    @tables_views_to_hide.each &:hide
    @widgets_to_disable.each{ |x| x.enabled = false }
    #@db.disconnect
  end

  def on_quitAction_triggered
    on_closeAction_triggered
    recent = @ui.recentMenu.actions
    Settings[:recent, :files] = recent[1..recent.size-1].map{ |a| a.data.value.to_s }.join(' ')
    puts 'Sayonara!'
    Qt::Application.quit
  end

  def on_verifyLecturersAction_triggered
    date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    dates = date.monday..date.monday + 6
    v = Verificator.new(dates)
    res = v.verify(:lecturer_studies).map do |k, v|
      date = k[0]
      lecturer = Lecturer.where(id: k[1]).first
      number = k[2]
      if lecturer.stub
        nil
      else
        v.each{ |study| @study_table_models[date.cwday - 1].setColor(study.id Qt::red) }
        "#{date} | #{lecturer} ведёт несколько пар одновременно! Номер пары: #{number}"
      end
    end
    res = res.compact.join("\n")
    console = ConsoleDialog.new self
    connect(@ui.verifyLecturersAction, SIGNAL('triggered()'), console, SLOT('close()'))
    console.show
    console.browser.append res
  end

  def on_verifyCabinetsAction_triggered
    date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    dates = date.monday..date.monday + 6
    v = Verificator.new(dates)
    res = v.verify(:cabinet_studies).map do |k, v|
      date = k[0]
      cabinet= Cabinet.where(id: k[1]).first
      number = k[2]
      if cabinet.stub
        nil
      else
        v.each{ |study| @study_table_models[date.cwday - 1].setColorCabinet(study.id, Qt::blue) }
        "#{date} | В #{cabinet.title} проходит несколько пар одновременно! Номер пары: #{number}"
      end
    end
    res = res.compact.join("\n")
    console = ConsoleDialog.new self
    connect(@ui.verifyCabinetsAction, SIGNAL('triggered()'), console, SLOT('close()'))
    console.show
    console.browser.append res
  end

  def on_showLecturerStubsAction_triggered
    date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    dates = date.monday..date.monday + 6
    v = Verificator.new(dates)
    res = v.verify(:lecturer_stubs).map do |date, studies|
      studies.map do |study|
        @study_table_models[date.cwday - 1].setColor(study.id, Qt::green)
        "#{date} | Не назначен преподаватель! Группа: #{study.get_group.title} Номер пары: #{study.number}"
      end.join("\n")
    end
    res = res.compact.join("\n")
    console = ConsoleDialog.new self
    connect(@ui.verifyLecturersAction, SIGNAL('triggered()'), console, SLOT('close()'))
    console.show
    console.browser.append res
  end

  def on_showCabinetStubsAction_triggered
    #date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    #dates = date.monday..date.monday + 6
    #v = Verificator.new(dates)
    #res = v.verify(:cabinet_stubs).map do |date, studies|
    #  studies.map do |study|
    #    @study_table_models[date.cwday - 1].setColorCabinet(study.groupable.get_group, study.number, Qt::green)
    #    "#{date} | Не назначен кабинет! Группа: #{study.get_group.title} Номер пары: #{study.number}"
    #  end.join("\n")
    #end
    #res = res.compact.join("\n")
    #console = ConsoleDialog.new self
    #connect(@ui.verifyLecturersAction, SIGNAL('triggered()'), console, SLOT('close()'))
    #console.show
    #console.browser.append res
  end

  def on_showSubjectsStubsAction_triggered
    #date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    #dates = date.monday..date.monday + 6
    #v = Verificator.new(dates)
    #res = v.verify(:subject_stubs).map do |date, studies|
    #  studies.map do |study|
    #    @study_table_models[date.cwday - 1].setColor(study.groupable.get_group, study.number, Qt::green)
    #    "#{date} | Не назначен предмет! Группа: #{study.get_group.title} Номер пары: #{study.number}"
    #  end.join("\n")
    #end
    #res = res.compact.join("\n")
    #console = ConsoleDialog.new self
    #connect(@ui.verifyLecturersAction, SIGNAL('triggered()'), console, SLOT('close()'))
    #console.show
    #console.browser.append res
  end

  def on_verifyAction_triggered
    #- группа и подгруппы в разных кабинетах
    #- проверка предметов всегда или никогда не проводимых в компьютерных кабинетах
  end

  class EntityItemModel < Qt::AbstractItemModel
    def initialize(entities, parent = nil)
      super(parent)
      @entities = entities
      @size = @entities.size
    end

    def index(row, column, parent)
      createIndex(row, column)
    end

    def parent(index)
      Qt::ModelIndex.new()
    end

    def columnCount(parent = self)
      1
    end

    def rowCount(parent = self)
      @size
    end

    def data(index, role = Qt::DisplayRole, data = nil)
      if role == Qt::DisplayRole && index.valid?
        @entities[index.row].to_s.to_v
      else
        Qt::Variant.new
      end
    end

    def flags(index)
      if index.valid?
        Qt::ItemIsDragEnabled | super(index)
      else
        super(index)
      end
    end

    def mimeData(indexes)
      entity = @entities[indexes.first.row]
      ba = Qt::ByteArray.new entity.id.to_s # Marshal.dump entity?
      mime_type = "application/#{entity.class.to_s.downcase}"
      mime_data = super indexes # для обхода ошибки сегментации Qt::MimeData создаётся с помощью родительского метода
      mime_data.setData(mime_type, ba)
      mime_data
    end
  end

  def show_tables
    @table_models = @table_views.map do |entity, table_model, table_view|
      model = table_model.new(entity.all)
      setup_table_view(table_view, model, Qt::HeaderView::Stretch)
      model
    end
    setup_study_table_views
    @ui.dateDateEdit.show
    @tables_views_to_hide.each(&:show)
    @widgets_to_disable.each{ |x| x.enabled = true }
    #@ui.studiesTableView.setSpan(0, 0, 1, 3)
    model =  EntityItemModel.new(Subject.all, self)
    @ui.subjectsListView.setModel model
    model =  EntityItemModel.new(Lecturer.all, self)
    @ui.lecturersListView.setModel model
    model =  EntityItemModel.new(Cabinet.all, self)
    @ui.cabinetsListView.setModel model
  end

  def setup_study_table_views
    @ui.deleteAction.disconnect(SIGNAL('triggered()'))
    monday = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate)).monday
    @study_table_models = @study_table_views.each_with_index.map do |view, index|
      model = setup_study_table_view(view, monday + index)
      view.disconnect(SIGNAL('doubleClicked(QModelIndex)'))
      model.disconnect(SIGNAL('studySaved(QVariant)'))
      view.disconnect(SIGNAL('customContextMenuRequested(QPoint)'))
      connect(view, SIGNAL('doubleClicked(QModelIndex)'), model, SLOT('editStudy(QModelIndex)'))
      connect(model, SIGNAL('studySaved(QVariant)')){ |id| update_table_view_model(Study.where(id: id.value).first.date) }
      connect(@ui.deleteAction, SIGNAL('triggered()'), model, SLOT('removeData()'))
      connect(@ui.cancelVerifyingAction, SIGNAL('triggered()'), model, SLOT('cancelColoring()'))
      view.setContextMenuPolicy(Qt::CustomContextMenu)
      connect(view, SIGNAL('customContextMenuRequested(QPoint)'), model, SLOT('displayMenu(QPoint)'))
      model
    end
  end

  def update_table_view_model(date)
    @study_table_models[date.cwday - 1].refresh
  end

  def setup_study_table_view(view, date)
    model = StudyTableModel.new(date, view)
    view = setup_table_view(view, model, Qt::HeaderView::Interactive)
    model.columnCount.times{ |i| i.odd? ? view.setColumnWidth(i, 50) : view.setColumnWidth(i, 150) }
    model.rowCount.times{ |i| view.setRowHeight(i, 50) }
    model
  end

  Contract IsA[Qt::TableView], IsA[Qt::AbstractTableModel], IsA[Qt::Enum] => IsA[Qt::TableView]
  def setup_table_view(table_view, table_model, resize_mode)
    table_view.setModel(table_model)
    table_view.horizontalHeader.setResizeMode(resize_mode)
    table_view.verticalHeader.setResizeMode(resize_mode)
    table_view.show
    table_view
  end

  def open_file
    filename = sender.data.value.to_s
    if File.exist? filename
      Database.instance.connect_to filename
      update_recent filename
      show_tables
    end
  end

  Contract String => Qt::Action
  def create_recent_action(path)
    action = Qt::Action.new(path[path.size-10..path.size], self)
    connect(action, SIGNAL('triggered()'), self, SLOT('open_file()'))
    action.setData Qt::Variant.new(path); action
  end

  Contract String => Any
  def update_recent(filename)
    actions = @ui.recentMenu.actions
    if actions.size > 5
      @ui.recentMenu.clear
      @ui.recentMenu.addActions([@clear_recent_action] + actions[1..actions.size-1])
    else
      @ui.recentMenu.addAction create_recent_action(filename)
    end
  end

  def clear_recent_files
    @ui.recentMenu.clear
    @ui.recentMenu.addAction @clear_recent_action
  end

  def on_dateDateEdit_dateChanged
    setup_dateEdit(Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate)))
    setup_study_table_views if Database.instance.connected?
  end

  def setup_dateEdit(date)
    type = date.cweek.even? ? "Чётная" : "Нечётная"
    @ui.dateDateEdit.displayFormat = "Неделя №#{date.cweek} (#{type}) dddd - d MMMM yy"
  end

  def please_wait(&block)
    @ui.statusbar.showMessage 'Please, wait...'
    yield block
    @ui.statusbar.clearMessage
  end

  def on_showManualAction_triggered
    # binding doesn't include QHelpEngine
    #helpEngine Qt::HelpEngineCore('test.qhc')
    #links = helpEngine.linksForIdentifier('MyDialog::ChangeButton')
    #if links.count
    #  helpData = helpEngine.fileData links.constBegin.value
    #  if !helpData.isEmpty
    #    displayHelp helpData
    #  end
    #end
    Qt::DesktopServices::openUrl(Qt::Url.new('https://github.com/Noein/TMIS/wiki'))
  end

end
