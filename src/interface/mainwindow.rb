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
require './src/interface/models/study_table_model'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class MainWindow < Qt::MainWindow

  slots 'on_newAction_triggered()'
  slots 'on_openAction_triggered()'
  slots 'on_recentAction_triggered()'
  slots 'on_saveAction_triggered()'
  slots 'on_saveAsAction_triggered()'
  slots 'on_importAction_triggered()'
  slots 'on_exportAction_triggered()'
  slots 'on_closeAction_triggered()'
  slots 'on_quitAction_triggered()'
  slots 'on_settingsAction_triggered()'

  def initialize(parent = nil)
    super(parent)
    @ui = Ui::MainWindow.new
    @ui.setup_ui(self)
    @db = Database.instance
    @temp_file_name = 'NewTimetable.sqlite'
  end

  def on_newAction_triggered
    @db.connect_to(':memory:')
  end

  def on_openAction_triggered
    @db.connect_to(':memory:')
  end

  def on_recentAction_triggered
  end

  def on_saveAction_triggered
  end

  def on_saveAsAction_triggered
  end

  def on_importAction_triggered
    @ui.statusbar.showMessage('Please, wait...')
    filename = Qt::FileDialog::getOpenFileName(self, 'Open File', '', 'Spreadsheets(*.xls *.xlsx *.ods *.csv)')
    unless filename.nil?
      sheet = SpreadsheetCreater.create(filename)
      reader = TimetableReader.new(sheet, :first!)
      FileUtils.rm_f(@temp_file_name)
      @db.connect_to(@temp_file_name)
      TimetableManager.new(reader).save_to_db
      show_studies
    end
    @ui.statusbar.clearMessage
  end

  def on_exportAction_triggered
  end

  def on_closeAction_triggered
    @ui.studiesTableView.model = nil
    #@db.disconnect
    FileUtils.rm_f(@temp_file_name)
  end

  def on_quitAction_triggered
    on_closeAction_triggered
    puts 'Sayonara!'
    Qt::Application.quit
  end

  def show_studies
    studies = Study.all
    model = StudyTableModel.new(studies)
    @ui.studiesTableView.model = model
    @ui.studiesTableView.show
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
