# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Lecturer < ActiveRecord::Base
  has_many :studies
  has_many :emails, :as => :emailable

  before_destroy :set_stubs_for_studies

  Contract None => String
  def to_s
    "#{self.surname} #{self.name unless self.name.nil?} #{self.patronymic unless self.patronymic.nil?}"
  end

  def set_stubs_for_studies
    stub = Lecturer.where(stub: true).first
    studies.each do |s|
      s.lecturer = stub
      s.save
    end
  end
end
