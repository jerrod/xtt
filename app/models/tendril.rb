class Tendril < ActiveRecord::Base
  belongs_to :notifies, :polymorphic => true
  belongs_to :project

  validates_uniqueness_of :project_id, :scope => [ :notifies_type, :notifies_id ]
end
