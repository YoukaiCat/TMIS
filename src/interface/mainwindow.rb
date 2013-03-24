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
require './src/engine/database'
require './src/engine/import/timetable_manager'
require './src/engine/import/timetable_reader'
require './src/engine/import/spreadsheet_roo'
require './src/engine/export/timetable_exporter.rb'
require './src/engine/mailer/mailer'
require './src/interface/ui_mainwindow'
require './src/interface/forms/settings'
require './src/engine/models/cabinet'
require './src/engine/models/course'
require './src/engine/models/group'
require './src/engine/models/lecturer'
require './src/engine/models/semester'
require './src/engine/models/speciality'
require './src/engine/models/speciality_subject'
require './src/engine/models/study'
require './src/engine/models/subject'
require './src/engine/models/subgroup'
require './src/interface/models/cabinet_table_model'
require './src/interface/models/course_table_model'
require './src/interface/models/group_table_model'
require './src/interface/models/lecturer_table_model'
require './src/interface/models/semester_table_model'
require './src/interface/models/speciality_table_model'
require './src/interface/models/speciality_subject_table_model'
require './src/interface/models/study_table_model'
require './src/interface/models/subject_table_model'
require './src/interface/models/subgroup_table_model'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class MainWindow < Qt::MainWindow

  # File menu
  slots 'on_newAction_triggered()'
  slots 'on_openAction_triggered()'
  slots 'on_saveAction_triggered()'
  slots 'on_saveAsAction_triggered()'
  slots 'on_importAction_triggered()'
  slots 'on_exportAction_triggered()'
  slots 'on_closeAction_triggered()'
  slots 'on_quitAction_triggered()'
  # Tools menu
  slots 'on_settingsAction_triggered()'
  # Self
  slots 'open_file()'
  slots 'clear_recent_files()'

  def initialize(parent = nil)
    super(parent)
    @ui = Ui::MainWindow.new
    @ui.setup_ui(self)
    @ui.cabinetsTableView.visible = false
    @ui.coursesTableView.visible = false
    @ui.groupsTableView.visible = false
    @ui.lecturersTableView.visible = false
    @ui.semestersTableView.visible = false
    @ui.specialitySubjectsTableView.visible = false
    @ui.specialitiesTableView.visible = false
    @ui.studiesTableView.visible = false
    @ui.subgroupsTableView.visible = false
    @ui.subjectsTableView.visible = false
    @temp = ->(){ "#{Dir.mktmpdir('tmis')}/temp.sqlite" }
    add_clear_action = ->() do
      clear_recent = Qt::Action.new('Очистить', self)
      clear_recent.setData(Qt::Variant.new('clear'))
      connect(clear_recent, SIGNAL('triggered()'), self, SLOT('clear_recent_files()'))
      @ui.recentMenu.addAction(clear_recent)
      clear_recent
    end
    if Settings[:recent, :files].split.size > 0
      @recent = Settings[:recent, :files].split.map do |path|
        action = Qt::Action.new(path[path.size-10..path.size], self)
        action.setData(Qt::Variant.new(path))
        connect(action, SIGNAL('triggered()'), self, SLOT('open_file()'))
        action
      end
      @recent = [add_clear_action.()] + @recent
      @recent.each_cons(2) { |before, action| @ui.recentMenu.insertAction(before, action) }
    else
      @recent = [add_clear_action.()]
    end
  end

  def clear_recent_files
    @ui.recentMenu.clear
    clear_recent = Qt::Action.new('Очистить', self)
    clear_recent.setData(Qt::Variant.new('clear'))
    connect(clear_recent, SIGNAL('triggered()'), self, SLOT('clear_recent_files()'))
    @ui.recentMenu.addAction(clear_recent)
    @recent.clear.push(clear_recent)
  end

  def please_wait(&block)
    @ui.statusbar.showMessage('Please, wait...')
    yield block
    @ui.statusbar.clearMessage
  end

  def on_newAction_triggered
    Database.instance.connect_to(@temp.())
    show_tables
  end

  def show_tables
    # Переменные экземпляра используются для обхода бага:
    # http://stackoverflow.com/questions/9715548/cant-display-more-than-one-table-model-inheriting-from-the-same-class-on-differ
    @cabinet_model = CabinetTableModel.new(Cabinet.all)
    @ui.cabinetsTableView.model = @cabinet_model
    @ui.cabinetsTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.cabinetsTableView.show
    @course_model = CourseTableModel.new(Course.all)
    @ui.coursesTableView.model = @course_model
    @ui.coursesTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.coursesTableView.show
    @group_model = GroupTableModel.new(Group.all)
    @ui.groupsTableView.model = @group_model
    @ui.groupsTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.groupsTableView.show
    @lecturer_model = LecturerTableModel.new(Lecturer.all)
    @ui.lecturersTableView.model = @lecturer_model
    @ui.lecturersTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.lecturersTableView.show
    @semester_model = SemesterTableModel.new(Semester.all)
    @ui.semestersTableView.model = @semester_model
    @ui.semestersTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.semestersTableView.show
    @speciality_model = SpecialityTableModel.new(Speciality.all)
    @ui.specialitiesTableView.model = @speciality_model
    @ui.specialitiesTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.specialitiesTableView.show
    @speciality_subject_model = SpecialitySubjectTableModel.new(SpecialitySubject.all)
    @ui.specialitySubjectsTableView.model = @speciality_subject_model
    @ui.specialitySubjectsTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.specialitySubjectsTableView.show
    @study_model = StudyTableModel.new(Study.all)
    @ui.studiesTableView.model = @study_model
    @ui.studiesTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.studiesTableView.show
    @subgroup_modle = SubgroupTableModel.new(Subgroup.all)
    @ui.subgroupsTableView.model = @subgroup_modle
    @ui.subgroupsTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.subgroupsTableView.show
    @subject_model = SubjectTableModel.new(Subject.all)
    @ui.subjectsTableView.model = @subject_model
    @ui.subjectsTableView.horizontalHeader.setResizeMode(Qt::HeaderView::Stretch)
    @ui.subjectsTableView.show
  end

  Contract String => Any
  def update_recent(filename)
    action = Qt::Action.new(filename[filename.size-10..filename.size], self)
    action.setData(Qt::Variant.new(filename))
    connect(action, SIGNAL('triggered()'), self, SLOT('open_file()'))
    general = ->() do
      repeated_action = @recent.select{ |f| f.data.value.to_s == action.data.value.to_s }
      @ui.recentMenu.removeAction(repeated_action.first) unless repeated_action.empty?
      @recent = @recent.delete_if{ |f| f.data.value.to_s == action.data.value.to_s }.push(action)
    end
    case
    when @recent.size == 1
      @recent = @recent.push(action)
    when @recent.size > 4
      @ui.recentMenu.removeAction(@recent.shift)
      general.()
    else
      general.()
    end
    @ui.recentMenu.insertAction(@recent[-2], action)
  end

  def open_file
    filename = sender.data.value.to_s
    if File.exist? filename
      Database.instance.connect_to(filename)
      update_recent(filename)
      show_tables
    end
  end

  def on_openAction_triggered
    if (filename = Qt::FileDialog::getOpenFileName(self, 'Open File', '', 'TMIS databases (SQLite3)(*.sqlite)'))
      Database.instance.connect_to(filename)
      update_recent(filename)
      show_tables
    end
  end

  def on_saveAction_triggered
  end

  def on_saveAsAction_triggered
    if (filename = Qt::FileDialog::getSaveFileName(self, 'Save File', 'NewTimetable.sqlite', 'TMIS databases (SQLite3)(*.sqlite)'))
      FileUtils.cp(Database.instance.path, filename) unless Database.instance.path == filename
      Database.instance.connect_to(filename)
      update_recent(filename)
      show_tables
    end
  end

  def on_importAction_triggered
    please_wait do
      if (filename = Qt::FileDialog::getOpenFileName(self, 'Open File', '', 'Spreadsheets(*.xls *.xlsx *.ods *.csv)'))
        sheet = SpreadsheetCreater.create(filename)
        reader = TimetableReader.new(sheet, :first!)
        Database.instance.connect_to(@temp.())
        TimetableManager.new(reader).save_to_db
        show_tables
      end
    end
  end

  def on_exportAction_triggered
  end

  def on_closeAction_triggered
    @ui.cabinetsTableView.hide
    @ui.coursesTableView.hide
    @ui.groupsTableView.hide
    @ui.lecturersTableView.hide
    @ui.semestersTableView.hide
    @ui.specialitiesTableView.hide
    @ui.specialitySubjectsTableView.hide
    @ui.studiesTableView.hide
    @ui.subgroupsTableView.hide
    @ui.subjectsTableView.hide
    #@db.disconnect
  end

  def on_quitAction_triggered
    on_closeAction_triggered
    @recent.shift
    Settings[:recent, :files] = @recent.map{ |a| a.data.value.to_s }.join(' ')
    puts 'Sayonara!'
    Qt::Application.quit
  end

  def timetable_for_lecturer(lecturer)
    text = "Здравствуйте, #{lecturer.to_s}! Ваши пары на этой неделе:\n\n"
    grouped = lecturer.studies.group(:date, :number).group_by(&:date)
    grouped.each do |date, studies|
      text += "Дата: #{date}\n\n"
      studies.each do |s|
        text += "\t Номер: #{s.number}, группа: #{s.groupable.title}, предмет #{s.subject.title}, кабинет: #{s.cabinet.title}\n"
      end
    end
    text += "\nИтого пар: #{lecturer.studies.count}\n"

    Mailer.new(Settings[:mailer, :email], Settings[:mailer, :password]) do
      from    'tmis@kp11.ru'
      to      'noein93@gmail.com'
      subject 'Расписание'
      body     text
      add_file :filename => 'timetable.xls', :content => File.read(filename)
    end.send!
  end

  def on_settingsAction_triggered
    SettingsDialog.new.exec
  end

end
