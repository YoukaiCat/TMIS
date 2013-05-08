# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'active_record'
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
  Contract IsA[TimetableReader] => Any
  def initialize(timetable_reader)
    @reader = timetable_reader
    @days = {'понедельник' => Date.new(2013,2,11), 'вторник' => Date.new(2013,2,12), 'среда' => Date.new(2013,2,13), 'четверг' => Date.new(2013,2,14), 'пятница' => Date.new(2013,2,15), 'суббота' => Date.new(2013,2,16) }
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
      lecturer: add(Lecturer, { surname: study[:info][:lecturer][:surname],
                                name: study[:info][:lecturer][:name],
                                patronymic: study[:info][:lecturer][:patronymic] }),
      date: @days[day.gsub(' ', '')],
      number: study_number,
      groupable: groupable }
  end

  Contract Or[Float, String] => String
  def fix_cabinet(title)
    title.is_a?(Float) ? title.ceil.to_s : title
  end
end
