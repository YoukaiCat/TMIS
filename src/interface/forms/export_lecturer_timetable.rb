# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'settings'
require_relative 'ui_export_lecturer_timetable'
require_relative '../../engine/database'
require_relative '../../engine/models/lecturer'
require_relative '../../engine/export/timetable_exporter.rb'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ExportLecturerTimetableDialog < Qt::Dialog

  slots 'on_exportButtonBox_accepted()'
  slots 'on_exportButtonBox_rejected()'
  slots 'on_selectAllPushButton_pressed()'
  slots 'on_deselectAllPushButton_pressed()'
  slots 'on_saveCheckBox_toggled(bool)'

  def initialize(parent = nil)
    super parent
    @ui = Ui::ExportLecturerTimetableDialog.new
    @ui.setup_ui self
    @ui.dayDateEdit.setDate(Qt::Date.fromString(Date.parse('monday').to_s, Qt::ISODate))
    @ui.progressBar.visible = false
    Lecturer.all.each do |l|
      item = Qt::ListWidgetItem.new(l.to_s, @ui.lecturersListWidget)
      item.setData(Qt::UserRole, Qt::Variant.new(l.id))
      item.checkState = Qt::Unchecked
    end
  end

  def on_saveCheckBox_stateChanged
    checkbox_actions(sender, chk, unchk)
  end

  def on_saveCheckBox_toggled(checked)
    if checked
      if (path = Qt::FileDialog::getExistingDirectory(self, 'Open Directory', '/home', Qt::FileDialog::ShowDirsOnly | Qt::FileDialog::DontResolveSymlinks))
        @ui.folderPathLineEdit.text = path # force_encoding doesn't help because Qt changes the encoding to ASCII anyway
      end
    else
       @ui.folderPathLineEdit.text = ''
    end
  end

  def on_selectAllPushButton_pressed
    @ui.lecturersListWidget.count.times{|i| @ui.lecturersListWidget.item(i).setCheckState(Qt::Checked) }
  end

  def on_deselectAllPushButton_pressed
    @ui.lecturersListWidget.count.times{|i| @ui.lecturersListWidget.item(i).setCheckState(Qt::Unchecked) }
  end

  def on_exportButtonBox_accepted
    if @ui.modeComboBox.currentIndex == 0
      if (date = Date.parse(@ui.dayDateEdit.date.toString(Qt::ISODate))).monday?
        export(date..date + 5)
        close
      else
        show_message 'Дата не соответствует понедельнику'
      end
    elsif @ui.modeComboBox.currentIndex == 1
      export([Date.parse(@ui.dayDateEdit.date.toString(Qt::ISODate))])
      close
    end
  end

  def export(dates)
    # TODO распараллелить
    # TODO progressBar в процентах
    @ui.progressBar.visible = true
    @ui.progressBar.setRange(0, @ui.lecturersListWidget.count)
    if @ui.saveCheckBox.checkState == Qt::Checked and @ui.mailCheckBox.checkState == Qt::Checked
      @ui.lecturersListWidget.count.times do |i|
        @ui.progressBar.setValue(i)
        Qt::Application::processEvents
        if @ui.lecturersListWidget.item(i).checkState == Qt::Checked
          id = @ui.lecturersListWidget.item(i).data(Qt::UserRole)
          lecturer = Lecturer.where(id: id.to_i).first
          filename = File.join(File.expand_path(@ui.folderPathLineEdit.text.force_encoding('UTF-8')), "#{lecturer.surname}_timetable.xls")
          if File.exist? filename
            File.delete filename
            spreadsheet = SpreadsheetCreater.create filename
          else
            spreadsheet = SpreadsheetCreater.create filename
          end
          TimetableExporter2.new(spreadsheet, LecturerTimetableExportStratagy2.new(dates, lecturer)).export.save
          mail(lecturer, filename)
        end
      end
    elsif @ui.saveCheckBox.checkState == Qt::Checked
      @ui.lecturersListWidget.count.times do |i|
        @ui.progressBar.setValue(i)
        Qt::Application::processEvents
        if @ui.lecturersListWidget.item(i).checkState == Qt::Checked
          id = @ui.lecturersListWidget.item(i).data(Qt::UserRole)
          lecturer = Lecturer.where(id: id.to_i).first
          filename = File.join(File.expand_path(@ui.folderPathLineEdit.text.force_encoding('UTF-8')), "#{lecturer.surname}_timetable.xls")
          if File.exist? filename
            File.delete filename
            spreadsheet = SpreadsheetCreater.create filename
          else
            spreadsheet = SpreadsheetCreater.create filename
          end
          TimetableExporter2.new(spreadsheet, LecturerTimetableExportStratagy2.new(dates, lecturer)).export.save
        end
      end
    elsif @ui.mailCheckBox.checkState == Qt::Checked
      @ui.lecturersListWidget.count.times do |i|
        @ui.progressBar.setValue(i)
        Qt::Application::processEvents
        if @ui.lecturersListWidget.item(i).checkState == Qt::Checked
          id = @ui.lecturersListWidget.item(i).data(Qt::UserRole)
          lecturer = Lecturer.where(id: id.to_i).first
          filename = Dir.mktmpdir('tmis') + "/#{lecturer.surname}_timetable.xls"
          spreadsheet = SpreadsheetCreater.create filename
          TimetableExporter2.new(spreadsheet, LecturerTimetableExportStratagy2.new(dates, lecturer)).export.save
          mail(lecturer, filename)
        end
      end
    end
    # thread.join
    @ui.progressBar.visible = false
  end

  def mail(lecturer, filename)
    text = "Здравствуйте, #{lecturer.to_s}! Ваши пары на этой неделе:\n\n"
    grouped = lecturer.studies.group(:date, :number).group_by(&:date)
    grouped.each do |date, studies|
      text += "Дата: #{date}\n\n"
      studies.each do |s|
        text += "\t Номер: #{s.number}, группа: #{s.groupable.to_s}, предмет #{s.subject.title}, кабинет: #{s.cabinet.title}\n"
      end
    end
    text += "\nИтого пар: #{lecturer.studies.count}\n"
    # lecturer.emails.map do
    Mailer.new(Settings[:mailer, :email], Settings[:mailer, :password]) do
      from    'tmis@kp11.ru'
      to      'noein93@gmail.com'
      subject 'Расписание'
      body     text
      add_file :filename => 'timetable.xls', :content => File.read(filename)
    end.send!
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
