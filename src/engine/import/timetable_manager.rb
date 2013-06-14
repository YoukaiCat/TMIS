# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'active_record'
require 'date'
require_relative '../models/group'
require_relative '../models/subgroup'
require_relative '../models/subject'
require_relative '../models/lecturer'
require_relative '../models/cabinet'
require_relative '../models/study'
require_relative '../models/course'
require_relative '../models/semester'
require_relative 'timetable_reader'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
require_relative 'abstract_spreadsheet'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class TimetableManager
  Contract IsA[TimetableReader], Any => Any
  def initialize(timetable_reader, date)
    @reader = timetable_reader
    @days = {'понедельник' => date, 'вторник' => date + 1, 'среда' => date + 2, 'четверг' => date + 3, 'пятница' => date + 4, 'суббота' => date + 5 }
  end

  Contract None => Any
  def save_to_db
    Database.instance.transaction do
      create_subgroups
      (1..4).each{ |n| Course.create(number: n) }
      Course.all.zip(Course.all).flatten.each_with_index { |c, i| Semester.create(title: i, course: c) }
    end
  end

private
  Contract None => Any
  def create_subgroups
    @reader.groups.each do |data|
      group = Group.create(title: data[:title])
      subgroups = (1..2).map{ |i| Subgroup.create(group: group, number: i) }
      create_studies(data, group, subgroups)
    end
  end

  Contract Hash, Group, ArrayOf[Subgroup] => Any
  def create_studies(data, group, subgroups)
    data[:days].each do |day|
      day[:studies].each_with_index do |study, number|
        if study.size == 1
          if (s = study.first[:info][:subgroup])
            Study.create( get_study_options(study[0], day[:name], number.succ, subgroups[s.to_i - 1]) )
          else
            Study.create( get_study_options(study[0], day[:name], number.succ, group) )
          end
        else
          study.each_with_index do |sepstudy, subgroup_number|
            Study.create( get_study_options(sepstudy, day[:name], number.succ, subgroups[subgroup_number]) )
          end
        end
      end
    end
  end

  Contract IsA[Class], Hash => IsA[ActiveRecord::Base]
  def add(model, options)
    model.where(options).first_or_create
  end

  Contract Hash, String, Pos, Or[Group, Subgroup] => Hash
  def get_study_options(study, day, study_number, groupable)
    { subject: add(Subject, title: study[:info][:subject]),
      cabinet: study[:cabinet].nil? ? Cabinet.last : add(Cabinet, title: fix_cabinet(study[:cabinet])),
      lecturer: new_lecturer_or_stub(study),
      date: @days[day.mb_chars.downcase.to_s.gsub(' ', '')],
      number: study_number,
      groupable: groupable }
  end

  def new_lecturer_or_stub(study)
    if study[:info][:lecturer][:surname] && study[:info][:lecturer][:surname][/#{Settings[:stubs, :lecturer]}/i]
      Lecturer.where(stub: true).first
    else
      add(Lecturer, { surname: study[:info][:lecturer][:surname],
                      name: study[:info][:lecturer][:name],
                      patronymic: study[:info][:lecturer][:patronymic] })
    end
  end

  Contract Or[Num, String] => String
  def fix_cabinet(title)
    title.is_a?(Float) ? title.ceil.to_s : title.to_s
  end
end
