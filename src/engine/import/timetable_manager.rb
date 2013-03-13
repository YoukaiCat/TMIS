require './src/engine/models/group'
require './src/engine/models/subgroup'
require './src/engine/models/subject'
require './src/engine/models/lecturer'
require './src/engine/models/cabinet'
require './src/engine/models/study'

class TimetableManager

  def initialize(timetable_reader)
    @reader = timetable_reader
  end

  def save_to_db
    Database.instance.transaction { create_subgroups }
  end

private

  def create_subgroups
    @reader.groups.each do |data|
      group = Group.create(title: data[:title])
      subgroups = (1..2).map{ |i| Subgroup.create(group: group, number: i) }
      create_studies(data, group, subgroups)
    end
    self
  end

  def create_studies(data, group, subgroups)
    data[:days].each do |day|
      day[:studies].each_with_index do |study, number|
        if study.size == 1
          Study.create( get_study_options(study[0], number, group) )
        else
          study.each_with_index do |sepstudy, subgroup_number|
            Study.create( get_study_options(sepstudy, number, subgroups[subgroup_number]) )
          end
        end
      end
    end
  end

  def add(model, options)
    model.where(options).first_or_create
  end

  def get_study_options(study, study_number, groupable)
    { subject: add(Subject, title: study[:info][:subject]),
      cabinet: study[:cabinet].nil? ? Cabinet.last : add(Cabinet, title: study[:cabinet]),
      lecturer: add(Lecturer, surname: study[:info][:lecturer][:surname]),
      number: study_number,
      groupable: groupable }
  end

end
