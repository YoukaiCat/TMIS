# coding: UTF-8
class Subgroup < ActiveRecord::Base
  belongs_to :group
  has_many :studies, :as => :groupable,  :dependent => :destroy

  def group?
    false
  end

  def subgroup?
    true
  end

  def get_group
    self.group
  end

  def to_s
    "#{group.title} #{number} подгруппа"
  end
end
