# coding: UTF-8
class Study < ActiveRecord::Base
  belongs_to :groupable, :polymorphic => true
  belongs_to :subject
  belongs_to :lecturer
  belongs_to :cabinet

  def validate
  end

  def get_group
    groupable.get_group
  end

  def to_group?
    groupable_type == 'Group'
  end

  def to_subgroup?
    groupable_type == 'Subgroup'
  end

  def to_s
    if to_subgroup?
      "#{subject.title}\n#{lecturer}" + " (#{groupable.number}п)"
    else
      "#{subject.title}\n#{lecturer}"
    end
  end
end
