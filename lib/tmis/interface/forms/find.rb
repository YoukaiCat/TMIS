# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require_relative 'ui_find'
require_relative '../../engine/database'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
#include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class FindDialog < Qt::Dialog

  def initialize(entity, parent = nil)
    super parent
    @main = parent
    @ui = Ui::FindDialog.new
    @ui.setup_ui self
    @entity = entity
    case @entity
    when :lecturer
      @ui.findByLabel.text = "Фамилия преподавателя:"
      Lecturer.all.sort_by(&:surname).each{|x| @ui.findByComboBox.addItem(x.surname, x.id.to_v)}
      @ui.findByComboBox.setCurrentIndex(0)
    when :subject
      @ui.findByLabel.text = "Название предмета:"
      Subject.all.sort_by(&:title).each{|x| @ui.findByComboBox.addItem(x.title, x.id.to_v)}
      @ui.findByComboBox.setCurrentIndex(0)
    when :cabinet
      @ui.findByLabel.text = "Название кабинета:"
      Cabinet.all.sort_by(&:title).each{|x| @ui.findByComboBox.addItem(x.title, x.id.to_v)}
      @ui.findByComboBox.setCurrentIndex(0)
    else
      raise ArgumentError
    end
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Ok), SIGNAL('clicked()')){ ok }
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Cancel), SIGNAL('clicked()')){ cancel }
  end

  def ok
    @main.study_table_models.each do |model|
      model.cancelColoring
    end
    case @entity
    when :lecturer
      studies = Study.where(lecturer_id: @ui.findByComboBox.itemData(@ui.findByComboBox.currentIndex).to_i)
    when :subject
      studies = Study.where(subject_id: @ui.findByComboBox.itemData(@ui.findByComboBox.currentIndex).to_i)
    when :cabinet
      studies = Study.where(cabinet_id: @ui.findByComboBox.itemData(@ui.findByComboBox.currentIndex).to_i)
    else
      raise ArgumentError
    end
    studies.each do |study|
      @main.study_table_models.each do |model|
        model.setColor(study.id, Qt::green)
      end
    end
  end

  def cancel
    @main.study_table_models.each do |model|
      model.cancelColoring
    end
    close
  end

  def show_message(text)
    box = Qt::MessageBox.new
    box.setText text
    box.exec
  end
end
