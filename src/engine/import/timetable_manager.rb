class TimetableManager

  def initialize(timetable_reader)
    @reader = timetable_reader
  end

  def save_to_db()
    @reader.groups.map do |group|
      _group = add(Group, title: group[:title])
      group[:days].map do |day|
        day[:studies].each_with_index.map do |study, number|
          if study.size == 1
            add(Study, get_study_options(study[0], number, _group))
          else
            study.map do |sepstudy, subgroup_number|
              add(Study, get_study_options(sepstudy, number, add(Subgroup, { group_id: _group, number: subgroup_number })))
            end
          end
        end
      end
    end
  end

private

  def add(model, params)
    model.where(params).first_or_create
  end

  def get_study_options(study, study_number, groupable)
    { subject_id: add(Subject, title: study[:info][:subject]),
      cabinet_id: add(Cabinet, title: study[:cabinet]),
      lecturer_id: add(Lecturer, { surname: study[:info][:lecturer][:surname], name: study[:info][:lecturer][:name], patronymic: study[:info][:lecturer][:patronymic]}),
      number: study_number,
      groupable_id: groupable }
  end

end
