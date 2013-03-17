class Lecturer < ActiveRecord::Base
  has_many :studies

  def to_s
    "#{self.surname} #{self.name unless self.name.nil?} #{self.patronymic unless self.patronymic.nil?}"
  end

end
