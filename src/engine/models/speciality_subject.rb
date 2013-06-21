class SpecialitySubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :semester
  belongs_to :speciality
  belongs_to :lecturer
end
