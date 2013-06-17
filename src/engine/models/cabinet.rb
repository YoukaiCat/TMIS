class Cabinet < ActiveRecord::Base
  has_many :studies

  before_destroy :set_stubs_for_studies

  def set_stubs_for_studies
    stub = Cabinet.where(stub: true).first
    studies.each do |s|
      s.cabinet = stub
      s.save
    end
  end
end
