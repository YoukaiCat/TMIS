# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'ui_export_general_timetable'
require_relative '../../engine/database'
require_relative '../../engine/export/timetable_exporter.rb'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ExportGeneralTimetableDialog < Qt::Dialog

  slots 'on_exportButtonBox_accepted()'
  slots 'on_exportButtonBox_rejected()'
  slots 'on_browsePushButton_clicked()'

  def initialize(parent = nil)
    super parent
    @ui = Ui::ExportGeneralTimetableDialog.new
    @ui.setup_ui self
    @ui.dateDateEdit.setDate Qt::Date.fromString(Date.today.to_s, Qt::ISODate)
  end

  def on_browsePushButton_clicked
    @ui.pathLineEdit.text = Qt::FileDialog::getSaveFileName(self, 'Save File', 'NewTimetable.sqlite', 'XLS Spreadsheet(*.xls)')
  end

  def on_exportButtonBox_accepted
    if (filename = @ui.pathLineEdit.text).empty?
      show_message 'Выберите путь к файлу'
    else
      date = Date.parse @ui.dateDateEdit.date.toString(Qt::ISODate)
      filename = @ui.pathLineEdit.text.force_encoding 'UTF-8'
      export(date, filename)
      close
    end
  end

  def on_exportButtonBox_rejected
    close
  end

  def export(date, filename)
    if File.exist? filename
      File.delete filename
      spreadsheet = SpreadsheetCreater.create filename
    else
      spreadsheet = SpreadsheetCreater.create filename
    end
    if @ui.weeklyRadioButton.isChecked
      TimetableExporter.new(spreadsheet, GeneralTimetableExportStratagy.new(date.monday..date.monday + 5)).export.save
    else
      TimetableExporter.new(spreadsheet, GeneralTimetableExportStratagy.new([date])).export.save
    end
  end

  def show_message(text)
    box = Qt::MessageBox.new
    box.setText text
    box.exec
  end
end
