class Group < ActiveRecord::Base
  belongs_to :speciality
  belongs_to :course
  has_many :subgroups
  has_many :studies, :as => :groupable

  def group?
    true
  end

  def subgroup?
    false
  end
end
