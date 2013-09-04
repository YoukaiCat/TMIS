# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'settings'
require_relative 'ui_export_group_timetable'
require_relative '../../engine/database'
require_relative '../../engine/models/group'
require_relative '../../engine/export/timetable_exporter.rb'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
#include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ExportGroupTimetableDialog < Qt::Dialog

  slots 'on_exportButtonBox_accepted()'
  slots 'on_exportButtonBox_rejected()'
  slots 'on_selectAllPushButton_pressed()'
  slots 'on_deselectAllPushButton_pressed()'
  slots 'on_saveCheckBox_toggled(bool)'

  def initialize(initial_date, parent = nil)
    super parent
    @ui = Ui::ExportGroupTimetableDialog.new
    @ui.setup_ui self
    @ui.dayDateEdit.setDate(Qt::Date.fromString(initial_date.to_s, Qt::ISODate))
    @ui.progressBar.visible = false
    Group.all.each do |g|
      item = Qt::ListWidgetItem.new(g.to_s, @ui.groupsListWidget)
      item.setData(Qt::UserRole, Qt::Variant.new(g.id))
      item.checkState = Qt::Unchecked
    end
  end

  def on_saveCheckBox_stateChanged
    checkbox_actions(sender, chk, unchk)
  end

  def on_saveCheckBox_toggled(checked)
    if checked
      if (path = Qt::FileDialog::getExistingDirectory(self, 'Open Directory', Dir.home, Qt::FileDialog::ShowDirsOnly | Qt::FileDialog::DontResolveSymlinks))
        @ui.folderPathLineEdit.text = path # force_encoding doesn't help because Qt changes the encoding to ASCII anyway
      else
        @ui.folderPathLineEdit.text = Dir.home
      end
    else
       @ui.folderPathLineEdit.text = ''
    end
  end

  def on_selectAllPushButton_pressed
    @ui.groupsListWidget.count.times{|i| @ui.groupsListWidget.item(i).setCheckState(Qt::Checked) }
  end

  def on_deselectAllPushButton_pressed
    @ui.groupsListWidget.count.times{|i| @ui.groupsListWidget.item(i).setCheckState(Qt::Unchecked) }
  end

  def on_exportButtonBox_accepted
    if @ui.modeComboBox.currentIndex == 0
      date = Date.parse(@ui.dayDateEdit.date.toString(Qt::ISODate)).monday
      export(date..date + 5)
      close
    elsif @ui.modeComboBox.currentIndex == 1
      export([Date.parse(@ui.dayDateEdit.date.toString(Qt::ISODate))])
      close
    end
  end

  def export(dates)
    # TODO распараллелить
    # TODO progressBar в процентах
    @ui.progressBar.visible = true
    @ui.progressBar.setRange(0, @ui.groupsListWidget.count)
    if @ui.saveCheckBox.checkState == Qt::Checked and @ui.mailCheckBox.checkState == Qt::Checked
      @ui.groupsListWidget.count.times do |i|
        @ui.progressBar.setValue(i)
        Qt::Application::processEvents
        if @ui.groupsListWidget.item(i).checkState == Qt::Checked
          id = @ui.groupsListWidget.item(i).data(Qt::UserRole)
          group = Group.where(id: id.to_i).first
          path = @ui.folderPathLineEdit.text.force_encoding('UTF-8')
          if File.writable? path
            filename = File.join(path, "#{group.title}_timetable.xls")
            if File.exist? filename
              File.delete filename
              spreadsheet = SpreadsheetCreater.create filename
            else
              spreadsheet = SpreadsheetCreater.create filename
            end
            TimetableExporter.new(spreadsheet, GroupTimetableExportStratagy.new(dates, group)).export.save
            mail(group, filename)
          end
        end
      end
    elsif @ui.saveCheckBox.checkState == Qt::Checked
      @ui.groupsListWidget.count.times do |i|
        @ui.progressBar.setValue(i)
        Qt::Application::processEvents
        if @ui.groupsListWidget.item(i).checkState == Qt::Checked
          id = @ui.groupsListWidget.item(i).data(Qt::UserRole)
          group = Group.where(id: id.to_i).first
          path = @ui.folderPathLineEdit.text.force_encoding('UTF-8')
          if File.writable? path
            filename = File.join(path, "#{group.title}_timetable.xls")
            if File.exist? filename
              File.delete filename
              spreadsheet = SpreadsheetCreater.create filename
            else
              spreadsheet = SpreadsheetCreater.create filename
            end
            TimetableExporter.new(spreadsheet, GroupTimetableExportStratagy.new(dates, group)).export.save
            mail(group, filename)
          end
        end
      end
    elsif @ui.mailCheckBox.checkState == Qt::Checked
      @ui.groupsListWidget.count.times do |i|
        @ui.progressBar.setValue(i)
        Qt::Application::processEvents
        if @ui.groupsListWidget.item(i).checkState == Qt::Checked
          id = @ui.groupsListWidget.item(i).data(Qt::UserRole)
          group = Group.where(id: id.to_i).first
          filename = Dir.mktmpdir('tmis') + "/#{group.title}_timetable.xls"
          spreadsheet = SpreadsheetCreater.create filename
          TimetableExporter.new(spreadsheet, GroupTimetableExportStratagy.new(dates, group)).export.save
          mail(group, filename)
        end
      end
    end
    # thread.join
    @ui.progressBar.visible = false
  end

  def mail(group, filename)
    group.emails.select(&:email_valid?).each do |email|
      text = "Здравствуйте, куратор группы #{group.to_s}!\n" +
             "В прикреплённой электронной таблице находится расписание для вашей группы.\n"
      Mailer.new(Settings[:mailer, :email], Settings[:mailer, :password]) do
        from     'tmis@kp11.ru'
        to       email.email
        subject  'Расписание'
        body     text
        add_file filename
      end.send!
    end
  end

  def on_exportButtonBox_rejected
    close
  end

  def show_message(text)
    box = Qt::MessageBox.new
    box.setText text
    box.exec
  end
end
