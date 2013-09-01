# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'Qt'
require 'date'
require_relative 'ui_expand_changes'
require_relative '../../engine/database'
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
#include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class ExpandChangesDialog < Qt::Dialog

  slots 'on_buttonBox_accepted()'
  slots 'on_buttonBox_rejected()'

  def initialize(parent = nil)
    super(parent)
    @ui = Ui::ExpandChangesDialog.new
    @ui.setup_ui self
    @date = Date.parse(parent.ui.dateDateEdit.date.toString(Qt::ISODate))
    monday = Qt::Date.fromString(@date.monday.to_s, Qt::ISODate)
    @ui.fromDateDateEdit.setDate monday
    @ui.toDateDateEdit.setDate monday
  end

  def on_buttonBox_accepted
    from_monday = Date.parse(@ui.fromDateDateEdit.date.toString(Qt::ISODate)).monday
    to_date = Date.parse(@ui.toDateDateEdit.date.toString(Qt::ISODate))
    week_studies = Study.where(date: from_monday..(from_monday + 6))

    Database.instance.transaction do
    case @ui.evennessComboBox.currentIndex
    when 0
      if from_monday == to_date
      elsif to_date > from_monday
        dates = (from_monday + 7).upto(to_date).select{|date| (1..6).include? date.cwday }.to_a
        Study.where(date: (from_monday + 7)..to_date).each{|study| study.destroy }
        week_studies.each do |study|
          dates.each do |date|
            if study.date.cwday == date.cwday
              study = study.dup
              study.date = date
              study.save
            end
          end
        end
      elsif to_date < from_monday
        dates = (from_monday - 1).downto(to_date).select{|date| (1..6).include? date.cwday }.to_a
        Study.where(date: to_date...from_monday).each{|study| study.destroy }
        week_studies.each do |study|
          dates.each do |date|
            if study.date.cwday == date.cwday
              study = study.dup
              study.date = date
              study.save
            end
          end
        end
      end
    when 1
      if from_monday == to_date
      elsif to_date > from_monday
        dates = (from_monday + 7).upto(to_date).select{|date| date.cweek.even? && ((1..6).include? date.cwday) }.to_a
        Study.where(date: (from_monday + 7)..to_date).each{|study| study.destroy }
        week_studies.each do |study|
          dates.each do |date|
            if study.date.cwday == date.cwday
              study = study.dup
              study.date = date
              study.save
            end
          end
        end
      elsif to_date < from_monday
        dates = (from_monday - 1).downto(to_date).select{|date| date.cweek.even? && ((1..6).include? date.cwday) }.to_a
        Study.where(date: to_date...from_monday).each{|study| study.destroy }
        week_studies.each do |study|
          dates.each do |date|
            if study.date.cwday == date.cwday
              study = study.dup
              study.date = date
              study.save
            end
          end
        end
      end
    when 2
      if from_monday == to_date
      elsif to_date > from_monday
        dates = (from_monday + 7).upto(to_date).select{|date| date.cweek.odd? && ((1..6).include? date.cwday) }.to_a
        Study.where(date: (from_monday + 7)..to_date).each{|study| study.destroy }
        week_studies.each do |study|
          dates.each do |date|
            if study.date.cwday == date.cwday
              study = study.dup
              study.date = date
              study.save
            end
          end
        end
      elsif to_date < from_monday
        dates = (from_monday - 1).downto(to_date).select{|date| date.cweek.odd? && ((1..6).include? date.cwday) }.to_a
        Study.where(date: to_date...from_monday).each{|study| study.destroy }
        week_studies.each do |study|
          dates.each do |date|
            if study.date.cwday == date.cwday
              study = study.dup
              study.date = date
              study.save
            end
          end
        end
      end
    else
    end
    end
  end

  def on_buttonBox_rejected
    close
  end

  def show_message(text)
    box = Qt::MessageBox.new
    box.setText text
    box.exec
  end
end
