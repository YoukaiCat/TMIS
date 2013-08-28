class Cabinet < ActiveRecord::Base
  has_many :studies

  before_destroy :set_stubs_for_studies

  def to_s
    title
  end

  def set_stubs_for_studies
    raise "Stub can't be destroyed!" if self.stub
    stub = Cabinet.where(stub: true).first
    studies.each do |s|
      s.cabinet = stub
      s.save
    end
  end
end
