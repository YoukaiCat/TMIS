#!/usr/bin/env ruby
# coding: UTF-8

# Copyright (C) 2013 Vladislav Mileshkin
#

require 'Qt'
require './src/interface/mainwindow'

Qt::Application.new(ARGV) do
  MainWindow.new do
    Ui::MainWindow.new.setupUi(self)
    show
  end
  exec
end
