class NotifiesController < ApplicationController
  def index
    @notifies = current_user.campfires.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @notifies }
      format.json { render :json => @notifies }
    end
  end

  def show
    @notifies = current_user.campfires.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @notifies }
      format.json { render :json => @notifies }
    end
  end

  def new
    @notifies = current_user.campfires.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @notifies }
      format.json { render :json => @notifies }
    end
  end

  def create
    @notifies = current_user.campfires.new(params[:notifies])

    respond_to do |format|
      if @notifies.save
        flash[:notice] = 'Notifies was successfully created.'
        format.html { redirect_to(notify_path(@notifies)) }
        format.xml  { render :xml  => @notifies, :status => :created, :location => notify_url(@notifies) }
        format.json { render :json => @notifies, :status => :created, :location => notify_url(@notifies) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @notifies.errors, :status => :unprocessable_entity }
        format.json { render :json => @notifies.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @notifies = current_user.campfires.find(params[:id])
  end

  def update
    @notifies = current_user.campfires.find(params[:id])

    respond_to do |format|
      if @notifies.update_attributes(params[:notifies])
        flash[:notice] = 'Notifies was successfully updated.'
        format.html { redirect_to(notify_path(@notifies)) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @notifies.errors, :status => :unprocessable_entity }
        format.json { render :json => @notifies.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @notifies = current_user.campfires.find(params[:id])
    @notifies.destroy

    respond_to do |format|
      format.html { redirect_to(notifies_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
