class Subject < ActiveRecord::Base
  has_many :studies
  has_many :speciality_subjects

  def to_s
    title
  end
end
