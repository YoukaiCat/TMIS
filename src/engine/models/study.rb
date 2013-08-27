# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Study < ActiveRecord::Base
  belongs_to :groupable, :polymorphic => true
  belongs_to :subject
  belongs_to :lecturer
  belongs_to :cabinet

  # Use Model#scoped instead of Model#all
  #Contract ActiveRecord::Relation => ActiveRecord::Relation::ActiveRecord_Relation_Group
  def self.of_groups_and_its_subgroups(groups)
    where_groups_or_subgroups(groups.select(:id), Subgroup.where(group_id: groups.select(:id)))
  end

  Contract Group => ActiveRecord::Relation
  def self.of_group_and_its_subgroups(group)
    where_groups_or_subgroups(group.id, Subgroup.where(group_id: group.id))
  end

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
    begin
    if to_subgroup?
      "#{subject.title}\n#{lecturer}" + " (#{groupable.number}п)"
    else
      "#{subject.title}\n#{lecturer}"
    end
    rescue #FIXME
      'ERROR'
    end
  end

private

  def self.where_groups_or_subgroups(ids_of_groups, ids_of_subroups)
    where('(groupable_type = "Group" AND groupable_id in (?)) OR (groupable_type = "Subgroup" AND groupable_id in (?))', ids_of_groups, ids_of_subroups)
  end
  private_class_method :where_groups_or_subgroups
end
