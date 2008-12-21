require 'digest/sha1'
class User
  class << self
    attr_accessor :email_format
    attr_accessor :login_format
  end
  
  self.email_format = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$/
  self.login_format = /^[a-z0-9_-]+$/

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email,                :if => :not_openid?
  validates_presence_of     :password,                     :if => :password_required?
  validates_presence_of     :password_confirmation,        :if => :password_required?
  validates_length_of       :password, :within => 4..40,   :if => :password_required?
  validates_confirmation_of :password,                     :if => :password_required?
  validates_length_of       :login, :within => 2..40,      :if => :not_openid?
  validates_length_of       :email, :within => 2..200,     :if => :not_openid?
  validates_format_of       :login, :with => login_format, :if => :not_openid?
  validates_format_of       :email, :with => email_format, :if => :not_openid?
  validates_uniqueness_of   :login, :email
  validates_uniqueness_of   :identity_url,                 :unless => :not_openid?  
  validates_presence_of     :identity_url,                 :unless => :not_openid?  
  before_save :encrypt_password, :if => :not_openid?
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :aim_login, :identity_url

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now(Time.zone.now).utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def login=(value)
    unless value.nil?
      value.gsub! /[^\w\_\-]/, ''
      value.strip!
      value.downcase!
    end
    write_attribute :login, value
  end
  
  def email=(value)
    unless value.nil?
      value.strip!
      value.downcase!
    end
    write_attribute :email, value
  end

  def identity_url=(value)
    unless value.nil?
      value = value.strip
      value.downcase!
      value.gsub!(/^http[:]\/\//, '')
      value.gsub!(/\/$/, '')
      unless value.blank?
        value = value + "/"
        value = "http://#{value}" unless value =~ /^https/
      end
    end
    write_attribute :identity_url, value
  end

protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def not_openid?
    identity_url.blank?
  end

  def password_required?
    return false unless not_openid? # ugh
    crypted_password.blank? || !password.blank?
  end
end