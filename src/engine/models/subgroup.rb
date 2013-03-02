class Subgroup < ActiveRecord::Base
  belongs_to :group
  has_many :studies, :as => :groupable
end
