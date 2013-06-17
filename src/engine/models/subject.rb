class Subject < ActiveRecord::Base
  has_many :studies
  has_many :speciality_subjects

  before_destroy :set_stubs_for_studies

  def to_s
    title
  end

  def set_stubs_for_studies
    stub = Subject.where(stub: true).first
    studies.each do |s|
      s.subject = stub
      s.save
    end
  end
end
