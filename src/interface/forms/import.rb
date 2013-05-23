# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'ui_import'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ImportDialog < Qt::Dialog

  attr_reader :params

  slots 'on_buttonBox_accepted()'
  slots 'on_buttonBox_rejected()'

  def initialize(parent = nil)
    super parent
    @ui = Ui::ImportDialog.new
    @ui.setup_ui self
    @ui.dateEdit.setDate(Qt::Date.fromString(Date.parse('monday').to_s, Qt::ISODate))
    @params = {}
  end

  def on_buttonBox_accepted
    if (date = Date.parse(@ui.dateEdit.date.toString(Qt::ISODate))).monday?
      @params[:sheet] = @ui.sheetNumberSpinBox.value
      @params[:date] = date
      close
    else
      box = Qt::MessageBox.new
      box.setText('Дата не соответствует понедельнику')
      box.exec
    end
  end

  def on_buttonBox_rejected
    close
  end
end
