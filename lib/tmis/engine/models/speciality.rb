class Speciality < ActiveRecord::Base
  has_many :speciality_subjects,  :dependent => :destroy
end
