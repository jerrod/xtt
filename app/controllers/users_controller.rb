require 'fastercsv'
class UsersController < ApplicationController
  before_filter :find_user, :only => [:show, :edit, :update, :suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required,       :only => [:index, :show, :edit, :update]
  before_filter :admin_required,       :only => [:suspend, :unsuspend, :destroy, :purge]

  # private user dashboard 
  def index
  end

  # user status page
  def show
    @statuses, @date_range = @user.statuses.filter(params[:filter] ||= :weekly, :page => params[:page],
      :date => params[:date], :projects => (@user == current_user ? nil : current_user.projects))
    @hours       = @user.statuses.filtered_hours(params[:filter], :date => params[:date])
    @daily_hours = @user.statuses.filtered_hours(:daily, :date => params[:date])
    project_ids = returning(@statuses.collect { |s| s.project_id }) { |ids| ids.uniq! ; ids.compact! }
    # @projects = project_ids.empty? ? [] : Project.find_all_by_id(project_ids)
    @memberships = project_ids.empty? ? [] : Membership.find_for(@user.id, project_ids)
  end

  # user signup
  def new
    @user = User.new
  end
  
  def invite
    @invitation = Invitation.find_by_code params[:code] unless params[:code].blank?
    raise ActiveRecord::RecordNotFound unless @invitation
    @user       = User.new
    @user.email = @invitation.email
    render :action => 'new'
  end

  # user signup
  def create
    cookies.delete :auth_token
    @user       = User.new(params[:user])
    @invitation = Invitation.find_by_code(params[:code]) unless params[:code].blank?
    @user.register! if @user.valid?
    @user.activate! if @invitation && @user.email == @invitation.email
    if @user.errors.empty?
      if @invitation
        @invitation.project_ids.each do |project|
          @user.memberships.create(:project_id => project)
        end
        @invitation.destroy
      end
      self.current_user = @user
      flash[:notice] = "Thanks for signing up!#{"  Watch your email address for an activation link before you can log in." if @user.active?}"
      redirect_back_or_default(login_path)
    else
      render :action => 'new'
    end
  end

  # user activation
  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if current_user != :false && !current_user.active?
      current_user.activate!
      flash[:notice] = "Signup complete!  You might like to check out the Help section for how to get started."
    end
    redirect_back_or_default
  end
  
  def reset_password
    @user = User.find_by_email(params[:email]) unless params[:email].blank?
    if @user
      @user.reset_activation_code
      @user.save
      User::Mailer.deliver_forgot_password(@user)
      flash[:notice] = "Check #{@user.email.inspect} for an activation email."
      redirect_to login_path
    else
      flash[:notice] = "No user found for this email address."
      redirect_to login_path(:anchor => 'reset')
    end
  end
  
  # private user editing
  def edit
  end
  
  # private user editing
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # admin only
  def suspend
    @user.suspend! 
    redirect_to root_Path
  end

  # admin only
  def unsuspend
    @user.unsuspend! 
    redirect_to root_Path
  end

  # admin only
  def destroy
    @user.delete!
    redirect_to root_Path
  end

  # admin only
  def purge
    @user.destroy
    redirect_to root_Path
  end

protected
  def find_user
    return false unless logged_in?
    @user = current_user.permalink.to_s == params[:id] ? current_user : User.find_by_permalink(params[:id])
  end
  
  def authorized?
    return false unless logged_in?
    return true if admin?
    @user.nil? || @user == current_user || (action_name == 'show' && current_user.related_to?(@user))
  end
end
