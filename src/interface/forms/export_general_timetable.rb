# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'ui_export_general_timetable'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ExportGeneralTimetableDialog < Qt::Dialog

  attr_reader :params

  slots 'on_exportButtonBox_accepted()'
  slots 'on_exportButtonBox_rejected()'
  slots 'on_weeklyRadioButton_toggled(bool)'

  def initialize(parent = nil)
    super parent
    @ui = Ui::ExportGeneralTimetableDialog.new
    @ui.setup_ui self
    @ui.dateDateEdit.setDate(Qt::Date.fromString(Date.parse('monday').to_s, Qt::ISODate))
    @params = {}
  end

  def on_weeklyCheckBox_toggled(checked)
    if checked && !Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate)).monday?
      @ui.dateDateEdit.setDate(Qt::Date.fromString(Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate)).monday.to_s, Qt::ISODate))
    end
  end

  def on_exportButtonBox_accepted
    if @ui.weeklyRadioButton.isChecked
      @params[:weekly_date] = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
      p @params[:weekly_date]
    else
      @params[:daily_date] = Date.parse(@ui.dateDateEdit.date.toString(Qt::ISODate))
    end
    close
  end

  def on_exportButtonBox_rejected
    close
  end
end
