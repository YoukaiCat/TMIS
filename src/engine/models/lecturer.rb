class Lecturer < ActiveRecord::Base
  has_many :studies

  def to_s
    self.surname
  end

end
