class TendrilsController < ApplicationController

  def create
    @tendril = current_user.tendrils.new(params[:tendril])

    respond_to do |format|
      if @tendril.save
        flash[:notice] = 'Notifies was successfully created.'
        format.html { redirect_to(notify_path(@tendril.notifies)) }
        format.xml  { render :xml  => @tendril, :status => :created, :location => notify_url(@tendril.notifies) }
        format.json { render :json => @tendril, :status => :created, :location => notify_url(@tendril.notifies) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @tendril.errors, :status => :unprocessable_entity }
        format.json { render :json => @tendril.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @tendril = current_user.tendrils.find(params[:id])
    @tendril.destroy

    respond_to do |format|
      format.html { redirect_to(notify_url(@tendril.notifies)) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
