class MembershipsController < ApplicationController
  before_filter :load_membership_and_project
  before_filter :login_required
  
  def create
    @membership.save

    respond_to do |format|
      format.js
    end
  end
  
  def update
    @membership.update_attributes(params[:membership])
    respond_to do |format|
      format.html { redirect_to project_path(@project)}
    end
  end
  
  def destroy
    @membership.destroy

    respond_to do |format|
      format.js
    end
  end
  
protected
  def load_membership_and_project
    @membership = params[:id].blank? ? Membership.new(params[:membership]) : Membership.find(params[:id])
    @project    = @membership.project
  end
  
  def authorized?
    logged_in? && (admin? || @project.users.include?(current_user))
  end
end
