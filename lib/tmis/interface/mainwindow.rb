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
#require '#Contracts'
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
require_relative 'forms/find'
require_relative 'forms/settings'
require_relative 'forms/import'
require_relative 'forms/console'
require_relative 'forms/debug_console'
require_relative 'forms/export_general_timetable'
require_relative 'forms/export_lecturer_timetable'
require_relative 'forms/export_group_timetable'
require_relative 'forms/expand_changes'
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
  slots 'on_verifyComputerCabinetsAction_triggered()'
  slots 'on_verifyPreferredDaysAction_triggered()'
  # Main
  slots 'on_dateDateEdit_dateChanged()'
  # Self
  slots 'open_file()'
  slots 'clear_recent_files()'
  slots 'refreshTableViewModel(QVariant)'
  # help
  slots 'on_showManualAction_triggered()'
  # views buttons
  slots 'on_addCabinetPushButton_clicked()'
  slots 'on_removeCabinetPushButton_clicked()'
  slots 'on_addCoursePushButton_clicked()'
  slots 'on_removeCoursePushButton_clicked()'
  slots 'on_addGroupPushButton_clicked()'
  slots 'on_removeGroupPushButton_clicked()'
  slots 'on_addLecturerPushButton_clicked()'
  slots 'on_removeLecturerPushButton_clicked()'
  slots 'on_addSemesterPushButton_clicked()'
  slots 'on_removeSemesterPushButton_clicked()'
  slots 'on_addSpecialityPushButton_clicked()'
  slots 'on_removeSpecialityPushButton_clicked()'
  slots 'on_addSubgroupPushButton_clicked()'
  slots 'on_removeSubgroupPushButton_clicked()'
  slots 'on_addSubjectPushButton_clicked()'
  slots 'on_removeSubjectPushButton_clicked()'
  slots 'on_addSpecialitySubjectPushButton_clicked()'
  slots 'on_removeSpecialitySubjectPushButton_clicked()'
  #connect(@ui.addSpecialitySubjectPushButton, SLOT('clicked()'), self, SLOT('on_addSpecialitySubjectPushButton_clicked()'))
  #connect(@ui.removeSpecialitySubjectPushButton, SLOT('clicked()'), self, SLOT('on_removeSpecialitySubjectPushButton_clicked()'))

  slots 'on_tabWidget_currentChanged(int)'
  slots 'on_dataTabWidget_currentChanged(int)'

  slots 'on_findByLecturerAction_triggered()'
  slots 'on_findBySubjectAction_triggered()'
  slots 'on_findByCabinetAction_triggered()'

  slots 'on_allAction_triggered()'
  slots 'on_allCoincidenceAction_triggered()'
  slots 'on_allNotAssignedAction_triggered()'

  slots 'on_tarificationCheckBox_toggled(bool)'

  slots 'on_debugConsoleAction_triggered()'

  attr_reader :ui
  attr_reader :study_table_models

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
                     @ui.dayLabel, @ui.dayLabel2, @ui.dayLabel3, @ui.dayLabel4, @ui.dayLabel5, @ui.dayLabel6,
                     @ui.subjectsListView, @ui.lecturersListView, @ui.cabinetsListView, @ui.tarificationCheckBox,
                     @ui.addCabinetPushButton, @ui.addCoursePushButton, @ui.addGroupPushButton,
                     @ui.addSubgroupPushButton, @ui.addLecturerPushButton, @ui.addSemesterPushButton,
                     @ui.addSpecialityPushButton, @ui.addSpecialitySubjectPushButton, @ui.addSubjectPushButton,
                     @ui.removeCabinetPushButton, @ui.removeCoursePushButton, @ui.removeGroupPushButton,
                     @ui.removeSubgroupPushButton, @ui.removeLecturerPushButton, @ui.removeSemesterPushButton,
                     @ui.removeSpecialityPushButton, @ui.removeSpecialitySubjectPushButton, @ui.removeSubjectPushButton]
    @widgets_to_disable = [@ui.findMenu, @ui.exportMenu, @ui.verifyMenu, @ui.saveAsAction, @ui.expandChangesAction]
    @tables_views_to_hide.each(&:hide)
    @widgets_to_disable.each{ |x| x.enabled = false }
    modeActionGroup = Qt::ActionGroup.new(self)
    modeActionGroup.setExclusive(true)
    modeActionGroup.addAction(@ui.weeklyViewAction)
    modeActionGroup.addAction(@ui.dailyViewAction)
    @temp = ->(){ "#{Dir.mktmpdir('tmis')}/temp.sqlite" }
    connect(@ui.aboutQtAction, SIGNAL('triggered()')){ Qt::Application.aboutQt }
    connect(@ui.aboutProgramAction, SIGNAL('triggered()')){ AboutDialog.new.exec }
    connect(@ui.exportGeneralAction, SIGNAL('triggered()')) do
      ExportGeneralTimetableDialog.new(Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))).exec
    end
    connect(@ui.exportForLecturersAction, SIGNAL('triggered()')) do
      ExportLecturerTimetableDialog.new(Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))).exec
    end
    connect(@ui.exportForGroupsAction, SIGNAL('triggered()')) do
      ExportGroupTimetableDialog.new(Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))).exec
    end
    connect(@ui.settingsAction, SIGNAL('triggered()')){ SettingsDialog.new.exec }
    connect(@ui.expandChangesAction, SIGNAL('triggered()')){ ExpandChangesDialog.new(self).exec }
    @clear_recent_action = Qt::Action.new('Очистить', self)
    @clear_recent_action.setData Qt::Variant.new('clear')
    connect(@clear_recent_action, SIGNAL('triggered()'), self, SLOT('clear_recent_files()'))
    @ui.dateDateEdit.setDate(Qt::Date.fromString(Date.today.to_s, Qt::ISODate))
    setup_dateEdit(Date.today)
    @ui.recentMenu.clear
    @ui.recentMenu.addActions([@clear_recent_action] + Settings[:recent, :files].split.map{ |path| create_recent_action(path) })
    #Settings[:app, :first_run] = ''
    Settings.set_defaults_if_first_run
    @console = ConsoleDialog.new self
    connect(@console, SIGNAL('dialogClosed()')){ @study_table_models.each(&:cancelColoring) }
    $TARIFICATION_MODE = false
  end

  def on_newAction_triggered
    Database.instance.connect_to(@temp.())
    create_stubs
    Group.create(title: 'New')
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
        if Database.instance.connected?
          (id = ImportDialog.new(Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate)))).exec
        else
          (id = ImportDialog.new(Date.today)).exec
        end
        unless id.params.empty?
          #begin
            sheet = SpreadsheetCreater.create filename
            reader = TimetableReader.new(sheet, id.params[:sheet])
            monday = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate)).monday
            if Database.instance.connected?
              Database.instance.transaction do Study.where(date: (monday..(monday + 6))).each(&:delete) end
            else
              Database.instance.connect_to(@temp.())
              create_stubs
            end
            TimetableManager.new(reader, id.params[:date]).save_to_db
            show_tables
          #rescue => e
          #  show_message "При импорте произошли ошибки,\nтаблица не была импортирована.\nПроверьте структуру таблицы."
          #end
        end
      end
    end
  end

  def show_message(text)
    box = Qt::MessageBox.new
    box.setText text
    box.exec
  end

  def on_closeAction_triggered
    @tables_views_to_hide.each(&:hide)
    @widgets_to_disable.each{ |x| x.enabled = false }
    Database.instance.disconnect unless $TESTING
  end

  def on_quitAction_triggered
    on_closeAction_triggered
    recent = @ui.recentMenu.actions
    Settings[:recent, :files] = recent[1..recent.size-1].map{ |a| a.data.value.to_s }.join(' ')
    puts 'Sayonara!'
    Qt::Application.quit
  end

  def on_allAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append verifyLecturers
      @console.browser.append verifyCabinets
      @console.browser.append showComputerCabinets
      @console.browser.append showLecturerStubs
      @console.browser.append showCabinetStubs
      @console.browser.append showSubjectsStubs
      @console.browser.append showPreferredDays
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def on_allCoincidenceAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append verifyLecturers
      @console.browser.append verifyCabinets
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def on_allNotAssignedAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append showLecturerStubs
      @console.browser.append showCabinetStubs
      @console.browser.append showSubjectsStubs
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def verifyLecturers
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
        v.each do |study|
          tst = @study_table_models[date.cwday - 1]
          tst.setColor(study.id, Qt::red)
        end
        "#{date} | #{lecturer} ведёт несколько пар одновременно! Номер пары: #{number}"
      end
    end
    res = res.compact.join("\n")
  end

  def on_verifyLecturersAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append verifyLecturers
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def verifyCabinets
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
  end

  def on_verifyCabinetsAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append verifyCabinets
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def showLecturerStubs
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
  end

  def on_showLecturerStubsAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append showLecturerStubs
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def showCabinetStubs
    date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    dates = date.monday..date.monday + 6
    v = Verificator.new(dates)
    res = v.verify(:cabinet_stubs).map do |date, studies|
      studies.map do |study|
        @study_table_models[date.cwday - 1].setColorCabinet(study.id, Qt::green)
        "#{date} | Не назначен кабинет! Группа: #{study.get_group.title} Номер пары: #{study.number}"
      end.join("\n")
    end
    res = res.compact.join("\n")
  end

  def on_showCabinetStubsAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append showCabinetStubs
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def showSubjectsStubs
    date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    dates = date.monday..date.monday + 6
    v = Verificator.new(dates)
    res = v.verify(:subject_stubs).map do |date, studies|
      studies.map do |study|
        @study_table_models[date.cwday - 1].setColor(study.id, Qt::green)
        "#{date} | Не назначен предмет! Группа: #{study.get_group.title} Номер пары: #{study.number}"
      end.join("\n")
    end
    res = res.compact.join("\n")
  end

  def on_showSubjectsStubsAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append showSubjectsStubs
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def showComputerCabinets
    date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    dates = date.monday..date.monday + 6
    v = Verificator.new(dates)
    res = v.verify(:computer_cabinets).map do |date, studies|
      studies.map do |study|
        @study_table_models[date.cwday - 1].setColorCabinet(study.id, Qt::yellow)
        "#{date} | Занятие подгруппы проходит не в компьютерном кабинете! Группа: #{study.get_group.title} Номер пары: #{study.number}"
      end.join("\n")
    end
    res = res.compact.join("\n")
  end

  def on_verifyComputerCabinetsAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append showComputerCabinets
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  def showPreferredDays
    date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    dates = date.monday..date.monday + 6
    v = Verificator.new(dates)
    res = v.verify(:preferred_days).map do |date, studies|
      studies.map do |study|
        @study_table_models[date.cwday - 1].setColorCabinet(study.id, Qt::yellow)
        "#{date} | #{study.lecturer.to_s} предпочитает вести занятия в другой день! Группа: #{study.get_group.title} Номер пары: #{study.number}"
      end.join("\n")
    end
    res = res.compact.join("\n")
  end

  def on_verifyPreferredDaysAction_triggered
    begin
      @console.browser.clear
      @console.show
      @console.browser.append showPreferredDays
    rescue
      show_message "При проверке произошли ошибки.\nПроверьте таблицы данных и расписание"
    end
  end

  #def groupAndSubgroup
  #  date = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
  #  dates = date.monday..date.monday + 6
  #  v = Verificator.new(dates)
  #  res = v.verify(:group_and_subgroup).map do |k, v|
  #    date = k[0]
  #    lecturer = Lecturer.where(id: k[1]).first
  #    number = k[2]
  #    if lecturer.stub
  #      nil
  #    else
  #      v.each{ |study| @study_table_models[date.cwday - 1].setColor(study.id Qt::red) }
  #      "#{date} | #{lecturer} ведёт несколько пар одновременно! Номер пары: #{number}"
  #    end
  #  end
  #end
  #
  #def on_verifyGroupAndSubgroup
  #  @console.browser.clear
  #  @console.show
  #  @console.browser.append groupAndSubgroup
  #end

  class EntityItemModel < Qt::AbstractItemModel
    def initialize(lambda, parent = nil)
      super(parent)
      @get_entities = lambda
      @entities = @get_entities.()
      @size = @entities.size
    end

    def refresh
      @entities = @get_entities.()
      @size = @entities.size
      emit layoutChanged()
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
      model = table_model.new(entity.all, table_view)
      proxy_model = model
      setup_table_view(table_view, proxy_model, Qt::HeaderView::Stretch)
      model
    end
    setup_study_table_views
    @ui.dateDateEdit.show
    @tables_views_to_hide.each(&:show)
    @widgets_to_disable.each{ |x| x.enabled = true }
    #@ui.studiesTableView.setSpan(0, 0, 1, 3)
    model =  EntityItemModel.new(->(){ Subject.all }, self)
    @ui.subjectsListView.setModel model
    @ui.subjectsListView.show
    model =  EntityItemModel.new(->(){ Lecturer.all }, self)
    @ui.lecturersListView.setModel model
    @ui.lecturersListView.show
    model =  EntityItemModel.new(->(){ Cabinet.all }, self)
    @ui.cabinetsListView.setModel model
    @ui.cabinetsListView.show
  end

  def on_tarificationCheckBox_toggled(checked)
    if checked
      $TARIFICATION_MODE = true
      model =  EntityItemModel.new(->(){ [] }, self)
      @ui.subjectsListView.setModel model
      @ui.subjectsListView.show
      model =  EntityItemModel.new(->(){ [] }, self)
      @ui.lecturersListView.setModel model
      @ui.lecturersListView.show
    else
      $TARIFICATION_MODE = false
      model =  EntityItemModel.new(->(){ Subject.all }, self)
      @ui.subjectsListView.setModel model
      @ui.subjectsListView.show
      model =  EntityItemModel.new(->(){ Lecturer.all }, self)
      @ui.lecturersListView.setModel model
      @ui.lecturersListView.show
    end
  end

  def setupListViews(index)
    return false unless $TARIFICATION_MODE
    string = index.model.data(index, Qt::UserRole).toString
    if string.nil? || string.empty?
      model =  EntityItemModel.new(->(){ [] }, self)
      @ui.subjectsListView.setModel model
      @ui.subjectsListView.show
      model =  EntityItemModel.new(->(){ [] }, self)
      @ui.lecturersListView.setModel model
      @ui.lecturersListView.show
    else
      entity = Marshal.load(Base64.decode64(string))
      p entity
      if entity.class == Study
        group = entity.groupable.get_group
        course = group.course
        if course.nil?
          model =  EntityItemModel.new(->(){ [] }, self)
          @ui.subjectsListView.setModel model
          @ui.subjectsListView.show
          model =  EntityItemModel.new(->(){ [] }, self)
          @ui.lecturersListView.setModel model
          @ui.lecturersListView.show
        else
          semester = course.current_semester
          get_subjects = ->() do
            if entity.lecturer && entity.subject.stub
              SpecialitySubject.where(lecturer_id: entity.lecturer, speciality_id: group.speciality, semester_id: semester).map(&:subject)
            else
              SpecialitySubject.where(speciality_id: group.speciality, semester_id: semester).map(&:subject)
            end
          end
          get_lecturers = ->() do
            if entity.subject && entity.lecturer.stub
              SpecialitySubject.where(subject_id: entity.subject, speciality_id: group.speciality, semester_id: semester).map(&:lecturer)
            else
              SpecialitySubject.where(speciality_id: group.speciality, semester_id: semester).map(&:lecturer)
            end
          end
          model =  EntityItemModel.new(get_subjects, self)
          @ui.subjectsListView.setModel model
          @ui.subjectsListView.show
          model =  EntityItemModel.new(get_lecturers, self)
          @ui.lecturersListView.setModel model
          @ui.lecturersListView.show
        end
      elsif entity.class == Group
        group = entity
        course = group.course
        if course.nil?
          model =  EntityItemModel.new(->(){ [] }, self)
          @ui.subjectsListView.setModel model
          @ui.subjectsListView.show
          model =  EntityItemModel.new(->(){ [] }, self)
          @ui.lecturersListView.setModel model
          @ui.lecturersListView.show
        else
          semester = course.current_semester
          get_subjects = ->() do
            SpecialitySubject.where(speciality_id: group.speciality, semester_id: semester).map(&:subject)
          end
          get_lecturers = ->() do
            SpecialitySubject.where(speciality_id: group.speciality, semester_id: semester).map(&:lecturer)
          end
          model =  EntityItemModel.new(get_subjects, self)
          @ui.subjectsListView.setModel model
          @ui.subjectsListView.show
          model =  EntityItemModel.new(get_lecturers, self)
          @ui.lecturersListView.setModel model
          @ui.lecturersListView.show
        end
      end
    end
  end

  def filterListViews(study64)
    if study.subject

    end
    if study.lecturer

    end
  end

  def setup_study_table_views
    @ui.deleteAction.disconnect(SIGNAL('triggered()'))
    monday = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate)).monday
    @study_table_models = @study_table_views.each_with_index.map do |view, index|
      model = setup_study_table_view(view, monday + index)
      model.disconnect(SIGNAL('studySaved(QVariant)'))
      view.disconnect(SIGNAL('doubleClicked(QModelIndex)'))
      view.disconnect(SIGNAL('customContextMenuRequested(QPoint)'))
      view.disconnect(SIGNAL('clicked(QModelIndex)'))
      model.disconnect(SIGNAL('refreshTarification(QModelIndex)'))
      connect(view, SIGNAL('customContextMenuRequested(QPoint)'), model, SLOT('displayMenu(QPoint)'))
      connect(view, SIGNAL('clicked(QModelIndex)')){ |index| setupListViews(index) }
      connect(model, SIGNAL('refreshTarification(QModelIndex)')){ |index| setupListViews(index) }
      connect(view, SIGNAL('doubleClicked(QModelIndex)'), model, SLOT('editStudy(QModelIndex)'))
      #connect(model, SIGNAL('studySaved(QString)')){|study64| filterListViews(study64) }
      connect(model, SIGNAL('studySaved(QVariant)'), self, SLOT('refreshTableViewModel(QVariant)'))
      connect(@ui.deleteAction, SIGNAL('triggered()'), model, SLOT('removeData()'))
      connect(@ui.cancelVerifyingAction, SIGNAL('triggered()'), model, SLOT('cancelColoring()'))
      view.setContextMenuPolicy(Qt::CustomContextMenu)
      model
    end
  end

  def refreshTableViewModel(date_variant)
    @study_table_models[date_variant.value.dayOfWeek - 1].refresh
  end

  def setup_study_table_view(view, date)
    model = StudyTableModel.new(date, view)
    view = setup_table_view2(view, model, Qt::HeaderView::Interactive)
    model.columnCount.times{ |i| i.odd? ? view.setColumnWidth(i, 50) : view.setColumnWidth(i, 150) }
    model.rowCount.times{ |i| view.setRowHeight(i, 50) }
    model
  end

  def setup_table_view2(table_view, table_model, resize_mode)
    table_view.setModel(table_model)
    table_view.horizontalHeader.setResizeMode(resize_mode)
    table_view.verticalHeader.setResizeMode(resize_mode)
    table_view.show
    table_view
  end

  ##Contract IsA[Qt::TableView], IsA[Qt::AbstractTableModel], IsA[Qt::Enum] => IsA[Qt::TableView]
  def setup_table_view(table_view, table_model, resize_mode)
    table_view.setModel(table_model)
    table_view.horizontalHeader.setResizeMode(resize_mode)
    table_view.verticalHeader.setResizeMode(Qt::HeaderView::ResizeToContents)
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

  #Contract String => Qt::Action
  def create_recent_action(path)
    action = Qt::Action.new(path[path.size-10..path.size], self)
    connect(action, SIGNAL('triggered()'), self, SLOT('open_file()'))
    action.setData Qt::Variant.new(path); action
  end

  #Contract String => Any
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

  def on_addCabinetPushButton_clicked
    @ui.cabinetsTableView.model.insert_new
  end

  def on_removeCabinetPushButton_clicked
    @ui.cabinetsTableView.model.remove_current
  end

  def on_addCoursePushButton_clicked
    @ui.coursesTableView.model.insert_new
  end

  def on_removeCoursePushButton_clicked
    @ui.coursesTableView.model.remove_current
  end

  def on_addGroupPushButton_clicked
    @ui.groupsTableView.model.insert_new
  end

  def on_removeGroupPushButton_clicked
    @ui.groupsTableView.model.remove_current
  end

  def on_addLecturerPushButton_clicked
    @ui.lecturersTableView.model.insert_new
  end

  def on_removeLecturerPushButton_clicked
    @ui.lecturersTableView.model.remove_current
  end

  def on_addSemesterPushButton_clicked
    @ui.semestersTableView.model.insert_new
  end

  def on_removeSemesterPushButton_clicked
    @ui.semestersTableView.model.remove_current
  end

  def on_addSpecialitySubjectPushButton_clicked
    @ui.specialitySubjectsTableView.model.insert_new
  end

  def on_removeSpecialitySubjectPushButton_clicked
    @ui.specialitySubjectsTableView.model.remove_current
  end

  def on_addSpecialityPushButton_clicked
    @ui.specialitiesTableView.model.insert_new
  end

  def on_removeSpecialityPushButton_clicked
    @ui.specialitiesTableView.model.remove_current
  end

  def on_addSubgroupPushButton_clicked
    @ui.subgroupsTableView.model.insert_new
  end

  def on_removeSubgroupPushButton_clicked
    @ui.subgroupsTableView.model.remove_current
  end

  def on_addSubjectPushButton_clicked
    @ui.subjectsTableView.model.insert_new
  end

  def on_removeSubjectPushButton_clicked
    @ui.subjectsTableView.model.remove_current
  end

  def on_dataTabWidget_currentChanged(index)
    if Database.instance.connected?
      @table_views.each do |c, m, view|
        model = view.model
        model.refresh
        proxy_model = model
        view.model = proxy_model
      end
    end
  end

  def on_tabWidget_currentChanged(index)
    if Database.instance.connected?
      if index == 0
        @study_table_models.each(&:refresh)
        [@ui.subjectsListView, @ui.lecturersListView, @ui.cabinetsListView].each{|view| view.model.refresh }
      end
    end
  end

  def on_findByLecturerAction_triggered
    FindDialog.new(:lecturer, self).show
  end

  def on_findBySubjectAction_triggered
    FindDialog.new(:subject, self).show
  end

  def on_findByCabinetAction_triggered
    FindDialog.new(:cabinet, self).show
  end

  def on_debugConsoleAction_triggered
    DebugConsoleDialog.new(self).show
  end

end
