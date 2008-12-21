class Project < ActiveRecord::Base
  include Status::Methods

  has_permalink :name

  validates_presence_of :user_id, :name, :code

  belongs_to :user
  has_many :tendrils
  has_many :feeds
  has_many :memberships, :dependent => :delete_all
  has_many :users, :order => 'login', :through => :memberships do
    def include?(user)
      proxy_owner.user_id == user.id || (loaded? ? @target.include?(user) : exists?(user.id))
    end
  end

  before_validation_on_create :create_code
  after_create :create_membership_for_owner

  named_scope :all, :order => 'permalink'

  def editable_by?(user)
    users.include?(user)
  end

  def owned_by?(user)
    user && user_id == user.id
  end

  def to_param
    permalink
  end

protected
  def create_membership_for_owner
    memberships.create :user_id => user_id, :code => code
  end

  def create_code
    if code.blank?
      self.code = name.to_s.dup
      code.gsub!(/\W/, '')
      code.downcase!
    end
  end
end