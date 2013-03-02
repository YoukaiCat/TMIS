# coding: UTF-8

def random_date()
  "#{rand(1..12)}.#{rand(1..32)}.2013"
end

FactoryGirl.define do

  factory :group do
    title %w[ А-11 А-22 А-32 А-42 В-42 В-31 ].sample
    speciality
    course
  end

  factory :subgroup do |t|
    number { rand(1..2) }
    group
  end

  factory :subject do |t|
    title %w[ АИС, Математика, Русский, ООП, СУБД, Физкультура ].sample
  end

  factory :cabinet do |t|
    title %w[ Физ.Зал, 403, 301, 404, 118, 408 ].sample
  end

  factory :lecturer do |t|
    surname %w[ Иванов, Петров, Сидоров ].sample
    name %w[ Иван, Петр, Алесей ].sample
    patronymic %w[ Иванович, Петрович, Алексеевич ].sample
  end

  factory :study do |t|
    trait :whole_group do
      association :groupable, factory: :group
    end
    trait :separated_group do
      association :groupable, factory: :subgroup
    end
    subject
    lecturer
    cabinet
    number { rand(1..6) }
    date { random_date }
  end

  factory :course do |t|
    number { rand(1..4) }
  end

  factory :speciality do |t|
    speciality %w[ АСОИиУ ВКСС ].sample
  end

  factory :semester do |t|
    title { rand(1..8).to_s }
    course
  end

  factory :speciality_subject do |t|
    subject
    semester
    speciality
    hours { rand(20..300) }
  end

end
