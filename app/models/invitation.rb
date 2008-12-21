class Invitation < ActiveRecord::Base
  validates_presence_of :code, :email
  validates_length_of   :email, :within => 2..200
  validates_format_of   :email, :with => User.email_format
  before_validation :set_code
  before_validation :write_project_ids_attribute
  
  def project_ids
    @project_ids ||= read_attribute(:project_ids).to_s.split(",").collect! { |id| id.strip! ; id }
  end

protected
  def set_code
    self.code ||= Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def write_project_ids_attribute
    write_attribute(:project_ids, project_ids * ", ")
  end
end
