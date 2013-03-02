class Semester < ActiveRecord::Base
  belongs_to :course
  has_many :speciality_subjects
end