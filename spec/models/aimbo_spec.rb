require File.dirname(__FILE__) + '/../spec_helper'
require 'im/response'


describe IM::Response do
  before do
    @user = mock_model(User)
    User.should_receive(:find_by_aim_login).with("joe").and_return(@user)
    @aim = mock("aim", :screen_name => "joe")
  end
  
  it "knows 'help'" do
    @aim.should_receive(:send_im).with("<HTML>I'm a time-tracker bot. Send me a status message like <b>@project hacking on \#54</b> or 'commands' for a list of commands</HTML>")
    im = IM::Response.new "help", @aim
  end
  
  it "knows 'projects'" do
    @user.stub!(:memberships).and_return [mock_model(Membership, :code => 'tt', :project => mock_model(Project, :name => 'Xtreem Time Tracker'))]
    @aim.should_receive(:send_im).with("<HTML>Your projects are: @tt (Xtreem Time Tracker)</HTML>")
    im = IM::Response.new "projects", @aim
  end
  
  it "creates a status" do
    @project = mock_model(Project, :name => "Fools!")
    @status  = mock_model(Status, :project => @project, :message => "thanks!")
    @user.should_receive(:post).with("@foo bar", 'AIM').and_return(@status)
    @aim.should_receive :send_im
    im = IM::Response.new "@foo bar", @aim
  end
  
  it "creates a status with no project" do
    @status = mock_model(Status, :message => "thanks!", :project => nil)
    @user.should_receive(:post).with("@foo bar", 'AIM').and_return(@status)
    @aim.should_receive :send_im
    im = IM::Response.new "@foo bar", @aim
  end
  
  it "responds with project name and code" do
    @project = mock_model(Project, :name => "Fools!", :code => "fools")
    @status  = mock_model(Status, :project => @project, :message => "thanks!", :user => @user)
    @user.stub!(:statuses).and_return mock('proxy', :latest => @status)
    @user.stub!(:memberships).and_return([])
    @user.memberships.stub!(:for).and_return mock_model(Membership, :code => 'fools')
    @aim.should_receive(:send_im).with("<HTML>Your current status is: <b>Fools! (@fools)</b> thanks!</HTML>")
    im = IM::Response.new "status", @aim
    
  end
end
