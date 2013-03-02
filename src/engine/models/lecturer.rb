class Lecturer < ActiveRecord::Base
  has_many :studies
end