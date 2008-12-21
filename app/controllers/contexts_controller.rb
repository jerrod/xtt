class ContextsController < ApplicationController
  before_filter :login_required, :except => :index
  before_filter :find_context,   :except => :index

  def index
    redirect_to root_path
  end

  def show
    @statuses, @date_range = Status.filter(user_status_for(params[:user_id]), params[:filter] ||= :weekly, :context => @context, :date => params[:date], :page => params[:page], :per_page => params[:per]||20)
    @daily_hours = Status.filtered_hours(user_status_for(params[:user_id]), :daily, :context => @context, :date => params[:date])
    @hours       = Status.filtered_hours(user_status_for(params[:user_id]), params[:filter], :context => @context, :date => params[:date])

    user_ids = @statuses.map {|s| s.user.permalink }.uniq
    @user_hours = []
    user_ids.each do |user|
      hours = Status.filtered_hours(user_status_for(user), params[:filter], :date => params[:date], :context => @context)
      @user_hours << hours unless hours.empty?
    end
    # reset @user var. hack. omg.
    user_status_for(params[:user_id])

    @context ||= Context.new :name => "etc"
    respond_to do |format|
      format.html # show.html.erb
      format.iphone
      format.xml  { render :xml  => @context }
      format.csv  # show.csv.erb
    end
  end

  def update
    @context.update_attributes params[:context]
    redirect_to context_path(@context)
  end

protected
  def find_context
    @context = current_user.contexts.find_by_permalink(params[:id]) unless params[:id].blank?
  end

  def user_status_for(status)
    @user = status == 'me' ? current_user : User.find_by_permalink(status)
    @user ? @user.id : nil
  end
end