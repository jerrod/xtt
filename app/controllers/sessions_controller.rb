# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # render new.rhtml
  layout 'session'
  def new
  end

  def create
    if using_open_id?
      openid_auth(params[:openid_url])
    else
      password_auth(params[:login], params[:password])
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default
  end


protected

  def openid_auth(identity_url)
    authenticate_with_open_id(identity_url, :required => [ :nickname, :email ]) do |status, identity_url, registration|
      case status.instance_variable_get("@code")
      when :missing
        failed_login "Sorry, the OpenID server couldn't be found"
      when :canceled
        failed_login "OpenID verification was canceled"
      when :failed
        failed_login "Sorry, the OpenID verification failed"
      when :successful
        if self.current_user = User.find_by_identity_url(identity_url)
          assign_registration_attributes!(registration)
          current_user.save!
          successful_login "Welcome!"
        elsif user = User.find_by_email(params['openid.sreg.email'])
          if user.identity_url.blank?
            failed_login "You already have an account under the email address listed with openID.  Login and add your OpenID url to your profile."
          else
            failed_login "You already have an account for the email address listed with openID, but your saved identity URL doesn't match.  Login and fix your identity URL."
          end
        # Sign up with openid
        #elsif self.current_user = User.create(:identity_url => identity_url)
        #  assign_registration_attributes!(registration)
        #  current_user.save!
        #  successful_login "Created your account, and welcome!"
        else
          failed_login "Sorry, no user by that identity URL exists"
        end
      else
        raise "WTF!? #{status.inspect}"
      end
    end
  end
  
  # registration is a hash containing the valid sreg keys given above
  # use this to map them to fields of your user model
  def assign_registration_attributes!(registration)
    model_to_registration_mapping.each do |model_attribute, registration_attribute|
      unless registration[registration_attribute].blank?
        current_user.send("#{model_attribute}=", registration[registration_attribute])
      end
    end
    current_user.activated_at ||= Time.now
    current_user.state = "active" # came from openID, fuck it. don't send a welcome email.
    current_user.save!
  end

  def model_to_registration_mapping
    { :email => 'email' } # nickname
  end
  
  def password_auth(login, password)
    self.current_user = User.authenticate(login, password)
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => current_user.remember_token , :expires => current_user.remember_token_expires_at }
      end
      successful_login "Logged in successfully"
    else
      failed_login "Invalid login or password."
    end
  end
  
  def failed_login(message)
    flash[:notice] = message
    render :action => "new"
  end
  
  def successful_login(message=nil)
    flash[:notice] = message
    redirect_back_or_default
  end

end
