# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require './src/interface/forms/ui_settings'
require './src/engine/mailer/mailer.rb'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Settings

  @@settings = Qt::Settings.new('settings.ini', 'Qt::Settings::IniFormat')

  Contract Symbol, Symbol => String
  def self.[](group, key)
    @@settings.beginGroup(group.to_s)
    result = @@settings.value(key.to_s)
    @@settings.endGroup()
    result.value.to_s
  end

  Contract Symbol, Symbol, Any => Any
  def self.[]=(group, key, value)
    @@settings.beginGroup(group.to_s)
    @@settings.setValue(key.to_s, Qt::Variant.new(value))
    @@settings.endGroup()
    @@settings.sync
  end
end

class SettingsDialog < Qt::Dialog

  slots 'on_buttonBox_accepted()'
  slots 'on_buttonBox_rejected()'

  def initialize(parent = nil)
    super(parent)
    @ui = Ui::SettingsDialog.new
    @ui.setup_ui(self)
    @ui.emailLineEdit.text = Settings[:mailer, :email]
    @ui.passwordLineEdit.text = Settings[:mailer, :password]
  end

  def on_buttonBox_accepted
    if Mailer.email_valid? @ui.emailLineEdit.text
      Settings[:mailer, :email] = @ui.emailLineEdit.text
      Settings[:mailer, :password] = @ui.passwordLineEdit.text
      close
    else
      @ui.titleLabel.text = 'Email имеет неправильный формат!'
    end
  end

  def on_buttonBox_rejected
    close
  end
end
