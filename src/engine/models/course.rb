class Course < ActiveRecord::Base
  has_many :semesters,  :dependent => :destroy
end
