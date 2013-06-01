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
require_relative 'forms/settings'
require_relative 'forms/import'
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
class MainWindow < Qt::MainWindow

  # File menu
  slots 'on_newAction_triggered()'
  slots 'on_openAction_triggered()'
  slots 'on_saveAction_triggered()'
  slots 'on_saveAsAction_triggered()'
  slots 'on_importAction_triggered()'
  slots 'on_exportGeneralAction_triggered()'
  slots 'on_exportForLecturersAction_triggered()'
  slots 'on_exportForGroupsAction_triggered()'
  slots 'on_closeAction_triggered()'
  slots 'on_quitAction_triggered()'
  # Tools menu
  slots 'on_settingsAction_triggered()'
  slots 'on_verifyAction_triggered()'
  # Main
  slots 'on_dateDateEdit_dateChanged()'
  # Self
  slots 'open_file()'
  slots 'clear_recent_files()'

  def initialize(parent = nil)
    super(parent)
    @ui = Ui::MainWindow.new
    @ui.setup_ui self
    @ui.exportMenu.enabled = false
    @study_table_views = [@ui.studiesTableView, @ui.studiesTableView2, @ui.studiesTableView3, @ui.studiesTableView4, @ui.studiesTableView5, @ui.studiesTableView6]
    @table_views = [[Cabinet, CabinetTableModel, @ui.cabinetsTableView], [Course, CourseTableModel, @ui.coursesTableView],
                    [Group, GroupTableModel, @ui.groupsTableView], [Lecturer, LecturerTableModel, @ui.lecturersTableView],
                    [Semester, SemesterTableModel, @ui.semestersTableView], [Speciality, SpecialityTableModel, @ui.specialitiesTableView],
                    [SpecialitySubject, SpecialitySubjectTableModel, @ui.specialitySubjectsTableView], [Subgroup, SubgroupTableModel, @ui.subgroupsTableView],
                    [Subject, SubjectTableModel, @ui.subjectsTableView]]
    # Следующие два атрибута используются для обхода бага связанного с работой GC http://stackoverflow.com/questions/9715548/cant-display-more-than-one-table-model-inheriting-from-the-same-class-on-differ
    @table_models = @study_table_models = []
    @tables_views_to_hide = [@ui.cabinetsTableView, @ui.coursesTableView, @ui.groupsTableView, @ui.lecturersTableView,
                     @ui.semestersTableView, @ui.specialitySubjectsTableView, @ui.specialitiesTableView,
                     @ui.studiesTableView, @ui.subgroupsTableView, @ui.subjectsTableView, @ui.dateDateEdit, @ui.exportMenu]
    @tables_views_to_hide.each &:hide
    @ui.exportMenu.enabled = false
    modeActionGroup = Qt::ActionGroup.new(self)
    modeActionGroup.setExclusive(true)
    modeActionGroup.addAction(@ui.weeklyViewAction)
    modeActionGroup.addAction(@ui.dailyViewAction)
    @temp = ->(){ "#{Dir.mktmpdir('tmis')}/temp.sqlite" }
    connect(@ui.aboutQtAction, SIGNAL('triggered()')){ Qt::Application.aboutQt }
    @clear_recent_action = Qt::Action.new('Очистить', self)
    @clear_recent_action.setData Qt::Variant.new('clear')
    connect(@clear_recent_action, SIGNAL('triggered()'), self, SLOT('clear_recent_files()'))
    @ui.dateDateEdit.setDate(Qt::Date.fromString(Date.today.to_s, Qt::ISODate))
    setup_dateEdit(Date.today)
    @ui.recentMenu.clear
    @ui.recentMenu.addActions([@clear_recent_action] + Settings[:recent, :files].split.map{ |path| create_recent_action(path) })
  end

  def on_newAction_triggered
    Database.instance.connect_to(@temp.())
    show_tables
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
          TimetableManager.new(reader, id.params[:date]).save_to_db
          show_tables
        end
      end
    end
  end

  def on_exportGeneralAction_triggered
    (ed = ExportGeneralTimetableDialog.new).exec
    unless ed.params.empty?
      if (filename = Qt::FileDialog::getSaveFileName(self, 'Save File', 'NewTimetable.sqlite', 'XLS Spreadsheet(*.xls)'))
        filename.force_encoding('UTF-8')
        if File.exist? filename
          File.delete filename
          spreadsheet = SpreadsheetCreater.create filename
        else
          spreadsheet = SpreadsheetCreater.create filename
        end
        if ed.params[:weekly_date]
          TimetableExporter.new(spreadsheet, GeneralTimetableExportStratagy.new(ed.params[:weekly_date]..ed.params[:weekly_date] + 5)).export.save
        elsif ed.params[:daily_date]
          TimetableExporter.new(spreadsheet, GeneralTimetableExportStratagy.new([ed.params[:daily_date]])).export.save
          #TimetableExporter.new(spreadsheet, GroupTimetableExportStratagy.new((ed.params[:daily_date]..(ed.params[:daily_date] + 5)), Group.first)).export.save
        end
      end
    end
  end

  def on_exportForLecturersAction_triggered
    ExportLecturerTimetableDialog.new.exec
  end

  def on_exportForGroupsAction_triggered
    ExportGroupTimetableDialog.new.exec
  end

  def on_closeAction_triggered
    @tables_views_to_hide.each &:hide
    @ui.exportMenu.enabled = false
    #@db.disconnect
  end

  def on_quitAction_triggered
    on_closeAction_triggered
    recent = @ui.recentMenu.actions
    Settings[:recent, :files] = recent[1..recent.size-1].map{ |a| a.data.value.to_s }.join(' ')
    puts 'Sayonara!'
    Qt::Application.quit
  end

  def on_settingsAction_triggered
    SettingsDialog.new.exec
  end

  def on_verifyAction_triggered
    # SELECT surname, count(surname)
    # FROM "lecturers"
    # group by surname
    # having count(surname) > 1
    # Lecturer.select('surname, count(surname)').group(:surname).having('count(surname) > 1')
    #- один преподаватель в odnoy pare
    #Study.select('number, lecturer_id, count(*)').where(date: Date.parse('Monday')).group('number, lecturer_id').having('count(*) > 1')
    text = ""
    (Date.parse('Monday')..Date.parse('Saturday')).each do |date|
      err = Study.select('number, lecturer_id, count(*)').where(date: date).group('number, lecturer_id').having('count(*) > 1')
      err.each do |e|
        if e
          text += "Обнаружена ошибка!\n#{date} преподаватель"+
                   " '#{Lecturer.where(id: e.lecturer_id).first.to_s}' "+
                   "ведёт несколько пар одновременно! Номер пары: #{e.number}.\n"
        end
      end
    end
    box = Qt::MessageBox.new
    box.setText(text)
    box.exec
    #- один преподаватель в двух аудиториях
    #- группа и подгруппы в разных кабинетах
    #- проверка предметов всегда или никогда не проводимых в компьютерных кабинетах
  end

  def show_tables
    @table_models = @table_views.map do |entity, table_model, table_view|
      model = table_model.new(entity.all)
      setup_table_view(table_view, model, Qt::HeaderView::Stretch)
      model
    end
    setup_study_table_views
    @ui.dateDateEdit.show
    @ui.exportMenu.enabled = true
    #@ui.studiesTableView.setSpan(0, 0, 1, 3)
  end

  def setup_study_table_views
    monday = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate)).monday
    studies = Study.of_groups_and_its_subgroups(Group.scoped)
    @study_table_models = @study_table_views.each_with_index.map do |view, index|
      day_studies = studies.where(date: monday + index).group_by(&:get_group).sort_by{ |f, s| f.title_for_sort }.map{ |f, s| [f, s.sort_by(&:number).group_by(&:number).to_a] }
      model = StudyTableModel.new(day_studies)
      view = setup_table_view(view, model, Qt::HeaderView::Interactive)
      model.columnCount.times{ |i| i.odd? ? view.setColumnWidth(i, 50) : view.setColumnWidth(i, 150) }
      model.rowCount.times{ |i| view.setRowHeight(i, 50) }
      model
    end
  end

  Contract IsA[Qt::TableView], IsA[Qt::AbstractTableModel], IsA[Qt::Enum] => IsA[Qt::TableView]
  def setup_table_view(table_view, table_model, resize_mode)
    table_view.model = table_model
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

end
