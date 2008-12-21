require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for User, 
  :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' do
    presence_of :login, :password, :password_confirmation, :email
end

describe User do
  define_models :users

  describe "being bootstrapped" do
    define_models :copy => false do
      model User
    end
  
    it "creates initial user as admin" do
      create_user.should be_admin
    end
  end
  
  describe "cached status associations" do
    define_models

    before do
      @user    = users(:default)
      @status  = statuses(:default)
      @project = projects(:default)
    end
    
    it "stores last status" do
      @user.last_status_id = @status.id
      @user.last_status.should == @status
    end
    
    it "stores last status project" do
      @user.last_status_project_id = @project.id
      @user.last_status_project.should == @project
    end
  end
  
  describe "#related_users" do
    define_models :copy => false do
      model User do
        stub :login => 'default'
        stub :thing_1, :login => 'thing_1', :last_status_at => current_time - 5.days
        stub :thing_2, :login => 'thing_2', :last_status_at => current_time - 3.days
        stub :the_cat, :login => 'the_cat'
      end
      
      model Project do
        stub :default, :name => 'default'
        stub :other, :name => 'other'
      end
      
      model Membership do
        stub :default, :user => all_stubs(:user), :project => all_stubs(:project)
        stub :other, :project => all_stubs(:other_project)
        stub :thing_1, :user => all_stubs(:thing_1_user)
        stub :thing_1_on_other, :user => all_stubs(:thing_1_user), :project => all_stubs(:other_project)
        stub :thing_2, :user => all_stubs(:thing_2_user), :project => all_stubs(:other_project)
      end
    end
    
    it "sorts #last_status_at" do
      users(:default).related_users.should == [users(:thing_2), users(:thing_1)]
    end
    
    all = [:default, :thing_1, :thing_2, :the_cat]
    {:default => [:thing_1, :thing_2], :thing_1 => [:default, :thing_2], :thing_2 => [:default, :thing_1], :the_cat => []}.each do |user, related|
      related.each do |rel|
        it "knows #{user} is related to #{rel}" do
          users(user).should be_related_to(users(rel))
        end
      end
      (all - related).each do |non|
        it "knows #{user} is not related to #{non}" do
          users(user).should_not be_related_to(users(non))
        end
      end
    end
  end
  
  describe "#can_access?(status)" do
    define_models :copy => false do
      model Project do
        stub :default, :name => 'default'
        stub :other, :name => 'other'
      end

      model User do
        stub :login => 'default'
        stub :other,   :login => 'other',   :last_status_project_id => 23
        stub :project, :login => 'project', :last_status_project => all_stubs(:project)
        stub :out,     :login => 'out',     :last_status_message => 'hi'
      end
      
      model Membership do
        stub :default, :user => all_stubs(:user), :project => all_stubs(:project)
      end
      
      model Status do
        stub :message => 'default', :user => all_stubs(:other_user)
        stub :user,    :message => 'same_user', :user => all_stubs(:user),       :project => all_stubs(:other_project)
        stub :project, :message => 'same_user', :user => all_stubs(:other_user), :project => all_stubs(:project)
        stub :other,   :message => 'same_user', :user => all_stubs(:other_user), :project => all_stubs(:other_project)
      end
    end
    
    before do
      @user = users(:default)
    end

    it "allows a status posted by the user" do
      @user.can_access?(statuses(:user)).should == true
    end

    it "allows a status posted in a user's project" do
      @user.can_access?(statuses(:project)).should == true
    end

    it "allows a status posted in a user's project (with loaded projects association)" do
      @user.projects.to_a # load projects association
      Membership.delete_all
      @user.can_access?(statuses(:project)).should == true
    end

    it "allows an OUT status" do
      @user.can_access?(statuses(:default)).should == true
    end

    it "doesn't access a status by a different user/project" do
      @user.can_access?(statuses(:other)).should == false
    end
    
    it "allows access to itself" do
      @user.can_access?(@user).should == true
    end

    it "allows a User#last_status posted in a user's project" do
      @user.can_access?(users(:project)).should == true
    end

    it "allows an OUT User#last_status" do
      @user.can_access?(users(:out)).should == true
    end

    it "doesn't access a User#last_status by a different user/project" do
      @user.can_access?(users(:other)).should == false
    end
  end
  
  describe "#post" do
    define_models :users
  
    before do
      @user = users(:default)
    end
    
    it "creates valid status" do
      lambda { @user.post "Foo" }.should change(Status, :count).by(1)
    end
    
    it "creates and maintains current 'out' status" do
      @status = @user.post "Foo"
      @status.project.should be_nil
    end
    
    it "changes project" do
      # assumes user's code == project's code
      @status = @user.post "@#{memberships(:default).code} Foo"
      @status.project.should == projects(:default)
    end
    
    it "changes user status to 'out' without code" do
      @user.last_status_project_id = projects(:default).id
      @status = @user.post "Foo"
      @status.project.should be_nil
    end
    
    it "changes user status to 'out'" do
      @user.last_status_project_id = projects(:default).id
      @status = @user.post "@ Foo"
      @status.project.should be_nil
    end
  end

  describe 'being created' do
    define_models :users
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it "increments User#count" do
      @creating_user.should change(User, :count).by(1)
    end
    
    it "starts in pending state" do
      @creating_user.call
      @user.reload.should be_pending
    end
    
    it "creates users as !admin" do
      @creating_user.call
      @user.should_not be_admin
    end
    
    it "initializes #activation_code" do
      @creating_user.call
      @user.reload.activation_code.should_not be_nil
    end
  end

  describe "being unsuspended" do
    define_models

    before do
      @user = users(:default)
      @user.suspend!
    end
    
    it 'reverts to active state' do
      @user.unsuspend!
      @user.should be_active
    end
    
    it 'reverts to passive state if activation_code and activated_at are nil' do
      User.update_all :activation_code => nil, :activated_at => nil
      @user.reload.unsuspend!
      @user.should be_passive
    end
    
    it 'reverts to pending state if activation_code is set and activated_at is nil' do
      User.update_all :activation_code => 'foo-bar', :activated_at => nil
      @user.reload.unsuspend!
      @user.should be_pending
    end
  end

  it 'resets password' do
    users(:default).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate(users(:default).login, 'new password').should == users(:default)
  end

  it 'does not rehash password' do
    users(:default).update_attributes(:login => users(:default).login.reverse)
    User.authenticate(users(:default).login, 'test').should == users(:default)
  end

  it 'authenticates user' do
    User.authenticate(users(:default).login, 'test').should == users(:default)
  end

  it 'sets remember token' do
    users(:default).remember_me
    users(:default).remember_token.should_not be_nil
    users(:default).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:default).remember_me
    users(:default).remember_token.should_not be_nil
    users(:default).forget_me
    users(:default).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:default).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:default).remember_token.should_not be_nil
    users(:default).remember_token_expires_at.should_not be_nil
    users(:default).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:default).remember_me_until time
    users(:default).remember_token.should_not be_nil
    users(:default).remember_token_expires_at.should_not be_nil
    users(:default).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:default).remember_me
    after = 2.weeks.from_now.utc
    users(:default).remember_token.should_not be_nil
    users(:default).remember_token_expires_at.should_not be_nil
    users(:default).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'suspends user' do
    users(:default).suspend!
    users(:default).should be_suspended
  end

  it 'does not authenticate suspended user' do
    users(:default).suspend!
    User.authenticate('quentin', 'test').should_not == users(:default)
  end

  it 'deletes user' do
    users(:default).deleted_at.should be_nil
    users(:default).delete!
    users(:default).deleted_at.should_not be_nil
    users(:default).should be_deleted
  end
  
  it 'finds owned projects' do
    users(:default).owned_projects.should == [projects(:another), projects(:default)]
  end
  
  it 'adds self as a member to the owned_projects after creation' do
    project = users(:default).owned_projects.create(:name => 'Ninjas')
    users(:default).projects.should include(project)
    project.memberships.should_not be_empty
  end
  
  describe "validation" do
    before do
      @user = create_user :login => nil # eh, don't save it
      @user.login = 'quire'
      # fail @user.error_messages.to_sentence unless @user.valid?
    end
    
    it "accepts valid login" do
      [' aaa ', 'bbb', 'cc1', 'dd1-2', 'ee1_3'].each do |l| 
        @user.login = l
        fail "#{l.inspect} is not valid" unless @user.valid?
      end
    end
    
    it "sanitizes invalid logins" do
      %w(! & ` , ? ' ").each do |char|
        @user.login = char + "AAA"
        fail "#{char.inspect} wasn't escaped. #{@user.login.inspect}" unless @user.valid? || @user.login != 'aaa'
      end
    end
    
    it "accepts valid emails" do
      %w(bob@foo.com bob+fred@foo.co.uk).each do |email|
        @user.email = email
        fail "#{email.inspect} is not valid" unless @user.valid?
      end
    end
    
    it "rejects invalid emails" do
      %w(! & ` , ? ' ").each do |char|
        @user.email = char + 'bob@foo.com'
        fail "#{@user.email.inspect} is valid" if @user.valid?
      end
    end
    
    it "requires either login or identity_url" do
      @user.login = "hello"
      @user.should be_valid

      @user.login = ""
      @user.identity_url = ""
      @user.should_not be_valid
      
      @user.login = "hello"
      @user.should be_valid
      
      @user.login = ""
      @user.identity_url = "http://hello.myplace.com"
      @user.should be_valid
    end
    
    it "fixes openid urls" do
      urls = { "poop.com" => "http://poop.com/", "https://poo.bah" => "https://poo.bah/", "http://poop" => "http://poop/" }
      urls.each do |key,value|
        @user.identity_url = key
        @user.identity_url.should == value
      end
    end
    
    it "requires a unique OpenID URL" do
      user1 = create_user(:login => "hey", :email => "hey@whatisthat.com", :identity_url => "poop.com")
      user1.save
      user1.identity_url.should == 'http://poop.com/'
      
      user2 = create_user(:login => "poop", :email => "heharr@peep.com", :identity_url => "poop.com")
      user2.should_not be_valid      
    end
    
    it "requires a unique e-mail" do
      user1 = create_user(:login => "thing", :email => "hey@hey.com")
      user1.save
      
      user2 = create_user(:login => "peep", :email => "hey@hey.com")
      user2.should_not be_valid      
    end
  end

protected
  def create_user(options = {})
    u = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    u.register! if u.valid?
    u
  end
end