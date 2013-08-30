class Group < ActiveRecord::Base
  belongs_to :speciality
  belongs_to :course
  has_many :subgroups, :dependent => :destroy
  has_many :studies, :as => :groupable, :dependent => :destroy
  has_many :emails, :as => :emailable,  :dependent => :destroy

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
    self.title[/(.*)-(.*)/i]; "#{$2}-#{$1}"
  end

  def to_s
    title
  end
end
