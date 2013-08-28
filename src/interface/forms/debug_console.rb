# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'ui_debug_console'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class DebugConsoleDialog < Qt::Dialog

  slots 'on_enterPushButton_pressed()'

  attr_accessor :browser

  def initialize(parent = nil)
    super parent
    @ui = Ui::DebugConsoleDialog.new
    @ui.setup_ui self
  end

  def on_enterPushButton_pressed
    res = '$'
    begin
      res = "#{Database.instance.instance_eval(@ui.lineEdit.text)}"
      p res
    rescue
      @ui.textEdit.setText("Error on #{@ui.lineEdit.text}")
    end
    @ui.textEdit.setText(res)
  end

end
