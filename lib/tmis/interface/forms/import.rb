# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'ui_import'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
#include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ImportDialog < Qt::Dialog

  attr_reader :params

  slots 'on_buttonBox_accepted()'
  slots 'on_buttonBox_rejected()'

  def initialize(initial_date, parent = nil)
    super parent
    @ui = Ui::ImportDialog.new
    @ui.setup_ui self
    monday = Qt::Date.fromString(initial_date.monday.to_s, Qt::ISODate)
    @ui.dateEdit.setDate(monday)
    @params = {}
  end

  def on_buttonBox_accepted
    date = Date.parse(@ui.dateEdit.date.toString(Qt::ISODate)).monday
    @params[:sheet] = @ui.sheetNumberSpinBox.value
    @params[:date] = date
    close
  end

  def on_buttonBox_rejected
    close
  end
end
