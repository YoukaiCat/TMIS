# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'ui_edit_study'
require_relative '../../engine/database'
require_relative '../../engine/models/lecturer'
#require_relative '../../engine/models/group'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class EditStudyDialog < Qt::Dialog

  slots 'on_groupComboBox_currentIndexChanged(int)'
  slots 'reset()'
  slots 'save()'

  def initialize(parent = nil)
    super parent
    @ui = Ui::EditStudyDialog.new
    @ui.setup_ui self
  end

  Contract Study => EditStudyDialog
  def setupData(study)
    @study = study
    # set group
    Group.all.sort_by(&:title_for_sort).each{|x| p "#{x.id} | #{x.id.to_v.to_i}"}
    Group.all.sort_by(&:title_for_sort).each{|x| @ui.groupComboBox.addItem(x.title, x.id.to_v)}
    @ui.groupComboBox.setCurrentIndex(@ui.groupComboBox.findData(study.groupable.get_group.id.to_v))
    # set subject
    Subject.all.sort_by(&:title).each{|x| @ui.subjectComboBox.addItem(x.title, x.id.to_v)}
    @ui.subjectComboBox.setCurrentIndex(@ui.subjectComboBox.findData(study.subject.id.to_v)) unless @study.new_record?
    # set lecturer
    Lecturer.all.sort_by(&:surname).each{|x| @ui.lecturerComboBox.addItem(x.to_s, x.id.to_v)}
    @ui.lecturerComboBox.setCurrentIndex(@ui.lecturerComboBox.findData(study.lecturer.id.to_v)) unless @study.new_record?
    # set cabinet
    Cabinet.all.sort_by(&:title).each{|x| @ui.cabinetComboBox.addItem(x.title.to_s, x.id.to_v)}
    @ui.cabinetComboBox.setCurrentIndex(@ui.cabinetComboBox.findData(study.cabinet.id.to_v)) unless @study.new_record?
    # set number
    (1..6).each{|x| @ui.numberComboBox.addItem(x.to_s, x.to_v)}
    @ui.numberComboBox.setCurrentIndex(@ui.numberComboBox.findData(study.number.to_v))
    @ui.dateDateEdit.setDate(Qt::Date.fromString(study.date.to_s, Qt::ISODate))
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Reset), SIGNAL('clicked()'), self, SLOT('reset()'))
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Save), SIGNAL('clicked()'), self, SLOT('save()'))
    connect(@ui.buttonBox.button(Qt::DialogButtonBox::Cancel), SIGNAL('clicked()')){ close }
    self
  end

  def on_groupComboBox_currentIndexChanged(index)
    @ui.subgroupComboBox.clear
    @ui.subgroupComboBox.addItem('Вся группа', 0.to_v)
    Subgroup.where(group_id: @study.groupable.get_group).each{|x| @ui.subgroupComboBox.addItem(x.number.to_s, x.id.to_v)}
    if @study.groupable.subgroup? && !@study.new_record?
      @ui.subgroupComboBox.setCurrentIndex(@ui.subgroupComboBox.findData(@study.groupable.id.to_v))
    else
      @ui.subgroupComboBox.setCurrentIndex(0)
    end
  end

  def reset
    [@ui.groupComboBox, @ui.subgroupComboBox, @ui.subjectComboBox, @ui.lecturerComboBox, @ui.cabinetComboBox,
     @ui.numberComboBox].each(&:clear)
    setupData(@study)
  end

  def save
    if @ui.subgroupComboBox.currentIndex == 0
      p @ui.groupComboBox.currentIndex
      p @ui.groupComboBox.itemData(@ui.groupComboBox.currentIndex).to_i
      group = Group.where(id: @ui.groupComboBox.itemData(@ui.groupComboBox.currentIndex).to_i).first
      @study.groupable_id = group.id
      @study.groupable_type = 'Group'
      p group
    else
      subgroup = Subgroup.where(id: @ui.subgroupComboBox.itemData(@ui.subgroupComboBox.currentIndex).to_i).first
      @study.groupable_id = subgroup.id
      @study.groupable_type = 'Subgroup'
    end
    @study.subject = Subject.where(id: @ui.subjectComboBox.itemData(@ui.subjectComboBox.currentIndex).to_i).first
    @study.lecturer = Lecturer.where(id: @ui.lecturerComboBox.itemData(@ui.lecturerComboBox.currentIndex).to_i).first
    @study.cabinet = Cabinet.where(id: @ui.cabinetComboBox.itemData(@ui.cabinetComboBox.currentIndex).to_i).first
    @study.number = @ui.numberComboBox.currentIndex + 1
    @study.date = Date.today.monday
    @study.save
    p @study
    close
  end

  def show_message(text)
    box = Qt::MessageBox.new
    box.setText text
    box.exec
  end
end
