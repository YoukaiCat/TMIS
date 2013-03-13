# coding: UTF-8

##
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
#

require 'Qt'
require './src/engine/database'
require './src/interface/ui_mainwindow'
require './src/engine/import/timetable_manager'
require './src/engine/import/timetable_reader'
require './src/engine/import/spreadsheet_roo'
require './src/interface/models/study_table_model'
require 'fileutils'

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

  def initialize(parent = nil)
    super(parent)
    @ui = Ui::MainWindow.new
    @ui.setup_ui(self)
    @db = Database.instance
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
    @ui.statusbar.showMessage("Please, wait...")
    filename = Qt::FileDialog::getOpenFileName(self, "Open File", "", "Spreadsheets(*.xls *.xlsx *.ods *.csv)")
    unless filename.nil?
      sheet = SpreadsheetRoo.new(filename)
      reader = TimetableReader.new(sheet, :even)
      FileUtils.rm_f('NewTimetable.sqlite')
      @db.connect_to('NewTimetable.sqlite')
      TimetableManager.new(reader).save_to_db
      show_studies
    end
    @ui.statusbar.clearMessage
  end

  def on_exportAction_triggered
  end

  def on_closeAction_triggered
    #@db.disconnect
    FileUtils.rm_f('NewTimetable.sqlite')
  end

  def on_quitAction_triggered
    on_closeAction_triggered
    puts "Sayonara!"
    Qt::Application.quit
  end

  def show_studies
    studies = Study.all
    model = StudyTableModel.new(studies)
    @ui.studiesTableView.model = model
    @ui.studiesTableView.show
  end

end
