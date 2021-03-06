# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'ui_console'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
#include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ConsoleDialog < Qt::Dialog

  signals 'dialogClosed()'

  attr_accessor :browser

  def initialize(parent = nil)
    super parent
    @ui = Ui::ConsoleDialog.new
    @ui.setup_ui self
    @browser = @ui.textBrowser
  end

  def closeEvent(event)
    emit dialogClosed
    event.accept
  end

end
