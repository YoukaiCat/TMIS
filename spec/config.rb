# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'simplecov'
require 'factory_girl'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require './src/engine/database'
require './src/engine/import/timetable_manager'
require './src/engine/import/timetable_reader'
require './src/engine/import/spreadsheet_roo'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
SimpleCov.command_name('Rspec')
SimpleCov.start do
  add_filter 'spec/'
  add_filter 'ui_*'
  add_group 'Interface', 'src/interface/'
  add_group 'Model', 'src/engine/models'
end

$DB = Database.instance.connect_to(':memory:')
# Загрузка данных для проверки
spreadsheet = SpreadsheetCreater.create('./spec/import/test_data/raspisanie_2013.csv')
reader = TimetableReader.new(spreadsheet, :first!)
TimetableManager.new(reader).save_to_db

# Возможно стоит использовать возможности RSpec вместо создания глобальной перепенной
#module DatabaseConnection
#  extend RSpec::SharedContext
#  let(:db) do
#    db = Database.instance.connect_to(':memory:')
#    spreadsheet = SpreadsheetFabric.create("./spec/import/test_data/raspisanie_2013.csv")
#    reader = TimetableReader.new(spreadsheet).week(0)
#    TimetableManager.new(reader).save_to_db
#    db
#  end
#end

RSpec.configure do |config|
  config.tty = true
  config.color_enabled = true
  config.formatter = :documentation
  config.include FactoryGirl::Syntax::Methods
  #config.include DatabaseConnection
end
