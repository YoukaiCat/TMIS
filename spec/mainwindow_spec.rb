# coding: UTF-8

require 'rspec'
require 'config'
require './src/interface/mainwindow'

describe MainWindow do
  before(:all) do
    @app = Qt::Application.new(ARGV)
    @mw = MainWindow.new
  end

  it "must print 'Sayonara!'" do
    $stdout.should_receive(:puts).with("Sayonara!")
    @mw.on_menuQuit_triggered
  end
end
