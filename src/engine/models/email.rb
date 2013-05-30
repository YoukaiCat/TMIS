# coding: UTF-8
class Email < ActiveRecord::Base
  belongs_to :emailable, :polymorphic => true

  def validate
  end

  def to_group?
    emailable_type == 'Group'
  end

  def to_lecturer?
    emailable_type == 'Lecturer'
  end
end
