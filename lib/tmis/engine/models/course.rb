class Course < ActiveRecord::Base
  has_many :semesters,  :dependent => :destroy

  def current_semester
    if Date.today.yday > 182
      semesters.first
    else
      semesters.last
    end
  end
end
