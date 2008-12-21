class FeedsController < ApplicationController
  def index
    @feeds = Feed.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @feeds }
      format.json { render :json => @feeds }
    end
  end

  def show
    @feed = Feed.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @feed }
      format.json { render :json => @feed }
    end
  end

  def new
    @feed = Feed.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @feed }
      format.json { render :json => @feed }
    end
  end

  def create
    @feed = Feed.new(params[:feed])

    respond_to do |format|
      if @feed.save
        flash[:notice] = 'Feed was successfully created.'
        format.html { redirect_to(@feed) }
        format.xml  { render :xml  => @feed, :status => :created, :location => @feed }
        format.json { render :json => @feed, :status => :created, :location => @feed }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @feed.errors, :status => :unprocessable_entity }
        format.json { render :json => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @feed = Feed.find(params[:id])
  end

  def update
    @feed = Feed.find(params[:id])

    respond_to do |format|
      if @feed.update_attributes(params[:feed])
        flash[:notice] = 'Feed was successfully updated.'
        format.html { redirect_to(@feed) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @feed.errors, :status => :unprocessable_entity }
        format.json { render :json => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy

    respond_to do |format|
      format.html { redirect_to(feeds_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
