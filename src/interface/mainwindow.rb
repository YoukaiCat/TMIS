# coding: UTF-8

# Copyright (C) 2013 Vladislav Mileshkin
# 

require 'Qt'
require './src/interface/ui_mainwindow'

class MainWindow < Qt::MainWindow

  slots 'on_menuQuit_triggered()'

  def on_menuQuit_triggered
    puts "Sayonara!"
    Qt::Application.quit
  end

end
