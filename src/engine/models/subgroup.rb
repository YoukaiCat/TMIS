class Subgroup < ActiveRecord::Base
  belongs_to :group
  has_many :studies, :as => :groupable

  def group?
    false
  end

  def subgroup?
    true
  end

  def get_group
    self.group
  end
end
