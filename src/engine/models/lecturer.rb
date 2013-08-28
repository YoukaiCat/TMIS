# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Lecturer < ActiveRecord::Base
  has_many :studies
  has_many :speciality_subjects
  has_many :emails, :as => :emailable, :dependent => :destroy

  before_destroy :set_stubs_for_studies

  Contract None => String
  def to_s
    "#{surname}#{(name.nil? ? '' : " #{name[0].mb_chars.capitalize.to_s}.")}#{(patronymic.nil? ? '' : " #{patronymic[0].mb_chars.capitalize.to_s}.")}"
  end

  def set_stubs_for_studies
    raise "Stub can't be destroyed!" if self.stub
    stub = Lecturer.where(stub: true).first
    studies.each do |s|
      s.lecturer = stub
      s.save
    end
  end
end
