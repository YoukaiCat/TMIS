# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../src/interface/mainwindow'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe MainWindow do
  before(:all) do
    @app = Qt::Application.new(ARGV)
    @mw = MainWindow.new
  end

  it "must print 'Sayonara!'" do
    $stdout.should_receive(:puts).with("Sayonara!")
    @mw.on_quitAction_triggered
  end
end
