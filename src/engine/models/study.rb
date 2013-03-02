class Study < ActiveRecord::Base
  belongs_to :groupable, :polymorphic => true
  belongs_to :subject
  belongs_to :lecturer
  belongs_to :cabinet
end