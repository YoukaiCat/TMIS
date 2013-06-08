class Group < ActiveRecord::Base
  belongs_to :speciality
  belongs_to :course
  has_many :subgroups
  has_many :studies, :as => :groupable
  has_many :emails, :as => :emailable

  def group?
    true
  end

  def subgroup?
    false
  end

  def get_group
    self
  end

  def number
    0
  end

  def title_for_sort
    title[/(.*)-(.*)/i]; "#{$2}-#{$1}"
  end

  def to_s
    title
  end
end
