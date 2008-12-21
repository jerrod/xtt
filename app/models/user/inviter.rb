class User::Inviter
  attr_reader :logins, :emails, :project
  
  def self.invite(project_id, string)
    i = new(project_id, string)
    i.invite
    i
  end
  
  def initialize(project_id, string)
    @project = Project.find_by_permalink(project_id) || raise(ActiveRecord::RecordNotFound)
    @emails, @logins = [], []
    parse(string)
  end
  
  def invite
    ActiveRecord::Base.transaction do
      users.each do |user|
        @project.users << user
        User::Mailer.deliver_project_invitation @project, user
      end
      invitations.each do |invite|
        User::Mailer.deliver_new_invitation @project, invite
      end
    end
  end
  
  def users
    if @users.nil?
      @users = @logins.empty? ? [] : User.find(:all, :conditions => {:login => @logins})
      @users.push(*User.find(:all, :conditions => ['email IN (?) and id NOT IN (?)', @emails, @users.collect { |u| u.id }]))
    end
    @users
  end
  
  def new_emails
    @new_emails ||= @emails - existing_emails
  end
  
  def existing_emails
    @existing_emails ||= users.collect { |u| u.email }
  end
  
  def invitations
    @invitations ||= new_emails.collect do |email| 
      inv = Invitation.find_or_initialize_by_email(email)
      inv.project_ids << @project.id.to_s
      inv.save! ; inv
    end
  end
  
  def to_job
    %{script/runner -e #{RAILS_ENV} 'User::Inviter.invite(#{@project.permalink.inspect}, "#{(logins + emails) * ", "}")'}
  end
  
protected
  def parse(string)
    string.split(',').each do |s| 
      s.strip! ; s.downcase!
      @emails << s if s =~ User.email_format
      @logins << s if s =~ User.login_format
    end
  end
end