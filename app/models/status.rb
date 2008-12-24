require 'tinder'

class Status < ActiveRecord::Base
  validate :set_project_from_code
  validates_presence_of :user_id, :message
  validate :times_are_sane
  
  concerns :hacky_date_methods, :filtering
  
  attr_writer :code_and_message
  attr_writer :followup
  attr_reader :active
  
  belongs_to :user
  belongs_to :project
  
  before_validation_on_create :parse_time_from_message
  after_create :cache_user_status
  after_create :process_previous
  
  acts_as_state_machine :initial => :pending
  state :pending
  state :processed
  
  event :process do
    transitions :from => :pending, :to => :processed, :guard => :calculate_hours
  end
  
  def membership
    @membership = (project? ? user.memberships.for(project) : nil) || false unless @membership == false
  end
  
  def code_and_message
    @code ?
      ("@#{@code} #{message}") :
      (membership ? "@#{membership.code} #{message}" : message)
  end

  def followup(reload = false)
    @followup   = nil if reload
    @followup ||= user.statuses.after(self) || :false
    @followup == :false ? nil : @followup
  end
  
  def previous(reload = false)
    @previous   = nil if reload
    @previous ||= user.statuses.before(self) || :false
    @previous == :false ? nil : @previous
  end
  
  def active?
    @active ||= followup.nil?
  end
  
  def out?
    !project?
  end
  
  def project?
    !project_id.nil?
  end

  def editable_by?(user)
    user &&
      (user.admin?         ||
      (user_id == user.id) || # status owner
      (project? && project.owned_by?(user))) # project owner
  end
  
  def code_and_message=(value)
    @code, self.message = extract_code_and_message(value)
  end

protected
  def set_project_from_code
    # Don't set the project if it's a new record and we have a project already. hm.
    unless new_record? && project?
      if @code.blank? # Don't set a project
        self.project = nil
        return
      end
      begin
        membership = user.memberships.find_by_code(@code)
        self.project = membership && membership.project
        unless project?
          errors.add_to_base("Invalid project code: @#{@code}") 
        end
      rescue Membership::InvalidCodeError
        errors.add_to_base("Invalid project code: @#{@code}") 
      end
    end
  end

  def parse_time_from_message
    return if message.blank? 
    message.strip!
    if message.gsub!(/\s*\[\-(\d+)\]$/, '')
      offset = $1.to_s.to_i
      #message.gsub!(/\s\[\-#{offset}\]/, '')
      self.created_at = Time.now - offset.minutes
    elsif message.gsub!(/\s*\[\-([\d\.]+)h(ours)?\]$/, '')
      offset = $1.to_s.to_f
      self.created_at = Time.now - offset.hours
      
    elsif message.gsub!(/\s*\[\-(\d+[:]\d+\s*)h?\]/, '')
      offset = Time.parse($1) - Time.parse("0:00")
      self.created_at = Time.now - offset
      
    elsif message.gsub!(/\s*\[(\d+[:]\d+(?:am|pm)?)\]$/, '')
      # This is faulty because it doesn't apply the user's timezone
      self.created_at = Time.parse($1)
    end
  end

  def extract_code_and_message(message)
    code = nil
    return [code, nil] if message.blank?
    message.sub! /\@\w*/ do |c|
      code = c[1..-1]; ''
    end
    [code, message.strip]
  end

  def calculate_hours
    # Can't calculate hours unless there's a 'next' state.
    return false if followup.nil?
    self.finished_at ||= followup.created_at
  end

  def process_previous
    user.statuses.find(:all, :conditions => ['state = ? AND finished_at IS NULL AND id != ?', 'pending', id]).each &:process!
    # previous.process! if previous
  end

  def cache_user_status
    User.update_all ['last_status_project_id = ?, last_status_id = ?, last_status_message = ?, last_status_at = ?', project_id, id, message, created_at], ['id = ?', user_id]
  end

  def times_are_sane
    if finished_at && created_at > finished_at
      errors.add_to_base "Can't finish before you start! (Extreme GTD)"
    end
  end
end
