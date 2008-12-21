class HelpController < ApplicationController
  def index
    @help = Help.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @help }
      format.json { render :json => @help }
    end
  end

  def show
    @help = Help.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @help }
      format.json { render :json => @help }
    end
  end

  def new
    @help = Help.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @help }
      format.json { render :json => @help }
    end
  end

  def create
    @help = Help.new(params[:help])

    respond_to do |format|
      if @help.save
        flash[:notice] = 'Help was successfully created.'
        format.html { redirect_to(@help) }
        format.xml  { render :xml  => @help, :status => :created, :location => @help }
        format.json { render :json => @help, :status => :created, :location => @help }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @help.errors, :status => :unprocessable_entity }
        format.json { render :json => @help.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @help = Help.find(params[:id])
  end

  def update
    @help = Help.find(params[:id])

    respond_to do |format|
      if @help.update_attributes(params[:help])
        flash[:notice] = 'Help was successfully updated.'
        format.html { redirect_to(@help) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @help.errors, :status => :unprocessable_entity }
        format.json { render :json => @help.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @help = Help.find(params[:id])
    @help.destroy

    respond_to do |format|
      format.html { redirect_to(help_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
