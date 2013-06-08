# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require_relative 'ui_settings'
require_relative '../../engine/mailer/mailer.rb'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Settings

  @@settings = Qt::Settings.new('settings.ini', 'Qt::Settings::IniFormat')

  Contract Symbol, Symbol => String
  def self.[](group, key)
    @@settings.beginGroup group.to_s
    result = @@settings.value key.to_s
    @@settings.endGroup()
    result.value.to_s.force_encoding('UTF-8')
  end

  Contract Symbol, Symbol, Any => Any
  def self.[]=(group, key, value)
    @@settings.beginGroup group.to_s
    @@settings.setValue(key.to_s, Qt::Variant.new(value))
    @@settings.endGroup()
    @@settings.sync
  end

  def self.reset!(group)
    case group
    when :mailer
      self[:mailer, :email] = 'email@example.com'
      self[:mailer, :password] = '12345'
    when :stubs
      self[:stubs, :lecturer] = 'Вакансия'
      self[:stubs, :cabinet] = 'Не назначен'
      self[:stubs, :subject] = 'Не назначен'
    else
      raise ArgumentError, 'No such settings group!'
    end
  end

  def self.set_defaults_if_first_run
    if Settings[:app, :first_run].empty?
      Settings[:app, :first_run] = 'false'
      self.reset! :mailer
      self.reset! :stubs
    end
  end
end

class SettingsDialog < Qt::Dialog

  slots 'apply()'
  slots 'ok()'
  slots 'restore()'
  slots 'help()'

  def initialize(parent = nil)
    super(parent)
    @ui = Ui::SettingsDialog.new
    @ui.setup_ui self
    @ui.stackedWidget.setCurrentIndex(0)
    setup
    connect(@ui.actionsListWidget, SIGNAL('currentRowChanged(int)'), @ui.stackedWidget, SLOT('setCurrentIndex(int)'))
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Ok), SIGNAL('clicked()'), self, SLOT('ok()'))
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Apply), SIGNAL('clicked()'), self, SLOT('apply()'))
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Help), SIGNAL('clicked()'), self, SLOT('help()'))
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::RestoreDefaults), SIGNAL('clicked()'), self, SLOT('restore()'))
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Cancel), SIGNAL('clicked()')){ close }

  end

  def setup
    @ui.emailLineEdit.text = Settings[:mailer, :email]
    @ui.passwordLineEdit.text = Settings[:mailer, :password]
    @ui.lecturerStubLineEdit.text = Settings[:stubs, :lecturer]
    @ui.cabinetStubLineEdit.text = Settings[:stubs, :cabinet]
    @ui.subjectStubLineEdit.text = Settings[:stubs, :subject]
  end

  def apply
    if Mailer.email_valid? @ui.emailLineEdit.text
      Settings[:mailer, :email] = @ui.emailLineEdit.text.force_encoding('UTF-8')
      Settings[:mailer, :password] = @ui.passwordLineEdit.text.force_encoding('UTF-8')
    else
      show_message 'Email имеет неправильный формат!'
      return false
    end
    Settings[:stubs, :lecturer] = @ui.lecturerStubLineEdit.text.force_encoding('UTF-8')
    Settings[:stubs, :cabinet] = @ui.cabinetStubLineEdit.text.force_encoding('UTF-8')
    Settings[:stubs, :subject] = @ui.subjectStubLineEdit.text.force_encoding('UTF-8')
    return true
  end

  def ok
    close if apply
  end

  def restore
    case @ui.stackedWidget.currentWidget.objectName
    when 'database'
      Settings.reset! :stubs
    when 'email'
      Settings.reset! :mailer
    when 'interface'
    when 'verify'
    when 'export'
    when 'import'
    else
    end
  end

  def help
  end

  def show_message(text)
    box = Qt::MessageBox.new(self)
    box.setText text
    box.exec
  end
end
