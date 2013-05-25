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

  def get_group
    self
  end

  def title_for_sort
    title[/(.*)-(.*)/i]; "#{$2}-#{$1}"
  end
end
