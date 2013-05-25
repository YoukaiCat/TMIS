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
  slots 'on_weeklyCheckBox_stateChanged()'
  slots 'on_dailyCheckBox_stateChanged()'

  def initialize(parent = nil)
    super parent
    @ui = Ui::ExportGeneralTimetableDialog.new
    @ui.setup_ui self
    @ui.weeklyDateEdit.setDate(Qt::Date.fromString(Date.parse('monday').to_s, Qt::ISODate))
    @ui.dailyDateEdit.setDate(Qt::Date.fromString(Date.parse('monday').to_s, Qt::ISODate))
    @ui.weeklyCheckBox.enabled = true
    @ui.weeklyCheckBox.checked = true
    @ui.dailyCheckBox.enabled = false
    @ui.dailyCheckBox.checked = false
    @params = {}
  end

  def on_weeklyCheckBox_stateChanged
    case sender.checkState
    when Qt::Checked
      @ui.dailyCheckBox.enabled = false
      @ui.dailyCheckBox.checked = false
    when Qt::Unchecked
      @ui.dailyCheckBox.enabled = true
      @ui.dailyCheckBox.checked = false
    end
  end

  def on_dailyCheckBox_stateChanged
    case sender.checkState
    when Qt::Checked
      @ui.weeklyCheckBox.enabled = false
      @ui.weeklyCheckBox.checked = false
    when Qt::Unchecked
      @ui.weeklyCheckBox.enabled = true
      @ui.weeklyCheckBox.checked = false
    end
  end

  def on_exportButtonBox_accepted
    if @ui.weeklyCheckBox.checkState == Qt::Checked
      if (date = Date.parse(@ui.weeklyDateEdit.date.toString(Qt::ISODate))).monday?
        @params[:weekly_date] = date
        close
      else
        box = Qt::MessageBox.new
        box.setText('Дата не соответствует понедельнику')
        box.exec
      end
    elsif @ui.dailyCheckBox.checkState == Qt::Checked
      @params[:daily_date] = Date.parse(@ui.dailyDateEdit.date.toString(Qt::ISODate))
      close
    end
  end

  def on_exportButtonBox_rejected
    close
  end
end
