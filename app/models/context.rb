class Context < ActiveRecord::Base
  has_many :memberships
  has_many :projects, :through => :memberships
  belongs_to :user

  has_permalink :name

  validates_uniqueness_of :name, :scope => :user_id

  attr_accessible :name, :permalink

  def users
    @users ||= User.for_projects(projects)
  end

  def to_param
    permalink
  end
end