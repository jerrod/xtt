require File.dirname(__FILE__) + '/../spec_helper'

describe User::Inviter do
  define_models :copy => false do
    model User do
      stub :login => 'default', :email => 'default@email.com'
      stub :foo, :login => 'foo', :email => 'baz@email.com'
      stub :bar, :login => 'bar', :email => 'bar@email.com'
    end
    
    model Project do
      stub :name => 'project'
    end
    
    model Membership
    model Invitation
  end
  
  before do
    @project = projects(:default)
    @string  = "FOO, bar , BAZ@email.com , newb@email.com"
    @inviter = User::Inviter.new(@project.permalink, @string)
  end

  it "parses logins" do
    @inviter.logins.should == %w(foo bar)
  end
  
  it "parses emails" do
    @inviter.emails.should == %w(baz@email.com newb@email.com)
  end
  
  it "shows new emails" do
    @inviter.new_emails.should == %w(newb@email.com)
  end
  
  it "retrieves unique users" do
    @inviter.should have(2).users
    @inviter.users.should include(users(:foo))
    @inviter.users.should include(users(:bar))
  end
  
  it "retrieves invitations" do
    @inviter.should have(1).invitations
    @inviter.invitations[0].project_ids.should == [@project.id.to_s]
    @inviter.invitations[0][:project_ids].should == @project.id.to_s
    @inviter.invitations[0].should_not be_new_record
    @inviter.invitations[0].code.should_not be_nil
    @inviter.invitations[0].email.should == 'newb@email.com'
  end
  
  it "retrieves adds extra project_id to existing invitation" do
    Invitation.create :email => 'newb@email.com', :project_ids => '55'
    @inviter.should have(1).invitations
    @inviter.invitations[0].project_ids.should   == ['55', @project.id.to_s]
    @inviter.invitations[0][:project_ids].should == "55, #{@project.id.to_s}"
  end
  
  it "creates memberships and emails users" do
    @inviter.users.each do |user|
      User::Mailer.should_receive(:deliver_project_invitation).with(@inviter.project, user)
    end
    @inviter.invitations.each do |invite|
      User::Mailer.should_receive(:deliver_new_invitation).with(@inviter.project, invite)
    end
    lambda { @inviter.invite }.should change(Membership, :count).by(2)
  end
  
  it "rejects invalid emails or logins" do
    ['', ', ; cat foo', ', && cat foo ', ', `cat foo`'].each do |extra|
      inviter = User::Inviter.new(@project.permalink, @string + extra)
      inviter.logins.should == @inviter.logins
      inviter.emails.should == @inviter.emails
      inviter.to_job.should == @inviter.to_job
    end
  end
  
  it "creates valid job string" do
    @inviter.to_job.should == %{script/runner -e test 'User::Inviter.invite(#{@project.permalink.inspect}, "foo, bar, baz@email.com, newb@email.com")'}
  end
end