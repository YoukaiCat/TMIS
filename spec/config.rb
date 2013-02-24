# coding: UTF-8

require 'simplecov'
require 'factory_girl'

SimpleCov.command_name("Rspec")
SimpleCov.start do
  add_filter "spec/"
  add_filter "ui_*"
  add_group "Interface", "src/interface/"
  add_group "Model", "src/engine/models"
end

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
  config.include FactoryGirl::Syntax::Methods
end
