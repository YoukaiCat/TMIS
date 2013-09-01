# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
#include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Lecturer < ActiveRecord::Base
  has_many :studies
  has_many :speciality_subjects
  has_many :emails, :as => :emailable, :dependent => :destroy

  before_destroy :set_stubs_for_studies

  #Contract None => String
  def to_s
    first = surname
    if name.nil?
      second = ""
    else
      if name.empty?
        second = name
      else
        second = name[0].mb_chars.capitalize.to_s
      end
    end
    if patronymic.nil?
      third = ""
    else
      if patronymic.empty?
        third = name
      else
        third = patronymic[0].mb_chars.capitalize.to_s
      end
    end
    "#{surname} #{second}.#{third}."
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
