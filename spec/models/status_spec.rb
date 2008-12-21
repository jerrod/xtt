require File.dirname(__FILE__) + '/../spec_helper'

describe Status do
  define_models :statuses
  # define_models :users
  
  it "#user retrieves associated User" do
    statuses(:default).user.should == users(:default)
  end
  
  it "#next retrieves followup status" do
    statuses(:in_project).followup.should == statuses(:pending)
  end

  it "does not allow time travel backwards" do
    pending "PDI"
    statuses(:in_project).previous.should == statuses(:default)
    lambda {
      statuses(:in_project).set_created_at = statuses(:default).created_at.utc - 10.minutes
      statuses(:in_project).errors.on(:created_at).should_not be_nil
    }.should_not change { statuses(:in_project).created_at }
    
    #}.should change { statuses(:in_project).valid? }.to(false)
    #statuses(:in_project).should_not be_valid
  end
  
  it "#next retrieves previous status" do
    statuses(:pending).previous.should == statuses(:in_project)
  end

  describe "#extract_code_and_message" do
    before do
      @status = Status.new
    end
    
    ['', ' '].each do |code|
      it "extracts nil code from #{code.inspect}" do
        @status.send(:extract_code_and_message, code + 'foo').should == [nil, "foo"]
      end
    end
    
    it "extracts nil code from '@'" do
      @status.send(:extract_code_and_message, ' @ foo').should == ['', "foo"]
    end
    
    it "strips whitespace from message" do
      @status.send(:extract_code_and_message, " foo ").should == [nil, "foo"]
    end
    
    ["@foo ", " @foo "].each do |code|
      it "extracts 'foo' code from #{code.inspect}" do
        @status.send(:extract_code_and_message, code + " bar ").should == %w(foo bar)
      end
    end
  end
end

describe Status, "being created" do
  define_models :statuses
  
  before do
    @status = statuses(:pending)
    @new    = @status.user.statuses.build(:message => 'howdy')
    @creating_status = lambda { @new.save! }
  end
  
  it "starts in :pending state" do
    @new.save!
    @new.should be_pending
  end
  
  it "increments user statuses count" do
    @creating_status.should change { @status.user.reload.statuses.size }.by(1)
  end
  
  it "is related properly to the previous status" do
    @new.save!
    @new.previous.should    == @status
    @status.followup.should == @new
  end
  
  it "processes previous status when creating" do
    @status.should be_pending
    @status.should be_valid
    @new.save!
    @status.user.should == @new.user
    @status.finished_at.should be_nil
    @status.reload.should be_processed
    @status.hours.to_f.should == 5.0
  end
  
  it "caches User#last_status_id" do
    @new.save!
    @status.user.reload.last_status.should == @new
  end
  
  it "caches User#last_status_message" do
    @new.save!
    @status.user.reload.last_status_message.should == @new.message
  end
  
  it "caches User#last_status_project_id" do
    @new.project = projects(:default)
    @new.save!
    @status.user.reload.last_status_project.should == @new.project
  end
  
  it "caches User#last_status_at" do
    @new.save!
    @status.user.reload.last_status_at.should == @new.created_at
  end

  it "sets the time in the past" do
    @new.message = "Howdy [-30]"
    @new.save!
    @new.created_at.should == Time.now - 30.minutes
    @new.message.should == "Howdy"
  end

  it "sets the start time manually" do
    @new.message = "Howdy [2:30pm]"
    @new.save!
    @new.created_at.should == Time.parse("14:30")
    @new.message.should == "Howdy"
  end
end

describe Status, "being updated" do
  define_models :statuses
  before do
    @status = statuses(:pending)
  end
  
  it "allows changed project" do
    @status.update_attributes(:code_and_message => "@def booya").should be_true
    @status.message.should == 'booya'
    @status.project.code.should == 'def'
  end
  
  it "allows changing to OUT" do
    @status.should_not be_out
    @status.update_attributes(:code_and_message => "booya").should be_true
    @status.message.should == 'booya'
    @status.project.should be_nil
    @status.should be_out
  end
  
  it "allows changed message" do
    @status.update_attributes(:code_and_message => "@abc booya").should be_true
    @status.message.should == 'booya'
    @status.user.memberships.for(@status.project).code.should == 'abc'
  end
  
  it "requires valid code, yet still updates message" do
    @status.update_attributes(:code_and_message => '@booya peeps').should be_false
    @status.message.should == 'peeps'
  end
end

describe "pending statuses", :shared => true do
  it "#next retrieves next status" do
    @status.followup.should == @new
  end
  
  it "skips processing if no followup is found" do
    @status.followup = :false
    @status.hours.should == 0
    @status.should be_pending
    @status.process!
    @status.should be_pending
  end
end

describe Status, "in pending state with followup in other project" do
  it_should_behave_like "pending statuses"

  define_models :copy => :statuses do
    model Status do
      stub :new_in_other_project, :message => '@def new_in_other_project', :created_at => (current_time - 2.hours), :project => all_stubs(:another_project)
    end
  end

  before do
    @new    = statuses(:new_in_other_project)
    @status = statuses(:pending)
    @new.code_and_message = @new.message
  end

  {0 => 0.0, 10 => 0.25, 15 => 0.25, 25 => 0.5, 30 => 0.5, 45 => 0.75}.each do |min, result|
    it "processes @status hours in quarters at #{min} minutes past the hour" do
      @new.created_at = @new.created_at + min.minutes
      @new.save!

      @status.hours.should == 0
      @status.should be_pending
      @status.process!
      @status.should be_processed
      @status.hours.to_s.should == (3.to_f + result).to_s
    end
  end
end

describe Status, "in pending state with followup in same project" do
  it_should_behave_like "pending statuses"

  define_models :copy => :statuses do
    model Status do
      stub :new_in_same_project, :message => '@abc new_in_same_project', :created_at => (current_time - 2.hours), :project => all_stubs(:project)
    end
  end

  before do
    @new    = statuses(:new_in_same_project)
    @status = statuses(:pending)
    @new.code_and_message = @new.message
  end

  {0 => 0.0, 10 => (1.0/6.0), 15 => 0.25, 25 => (25.0/60.0), 30 => 0.5, 45 => 0.75}.each do |min, result|
    it "processes @status hours in quarters at #{min} minutes past the hour" do
      @new.created_at = @new.created_at + min.minutes
      @new.save!

      @status.hours.should == 0
      @status.should be_pending
      @status.process!
      @status.should be_processed
      @status.hours.to_s.should == (3.to_f + result).to_s
    end
  end
end

describe Status, "in pending state with followup in no project" do
  it_should_behave_like "pending statuses"

  define_models :copy => :statuses do
    model Status do
      stub :new_without_project, :message => 'new_without_project', :created_at => (current_time - 2.hours)
    end
  end

  before do
    @new    = statuses(:new_without_project)
    @status = statuses(:pending)
  end

  {0 => 0.0, 10 => 0.25, 15 => 0.25, 25 => 0.5, 30 => 0.5, 45 => 0.75}.each do |min, result|
    it "processes @status hours in quarters at #{min} minutes past the hour" do
      @new.created_at = @new.created_at + min.minutes
      @new.save

      @status.hours.should == 0
      @status.should be_pending
      @status.process!
      @status.should be_processed
      @status.hours.to_s.should == (3.to_f + result).to_s
    end
  end
end

describe Status, 'permissions' do
  define_models do
    model User do
      stub :other, :login => 'other'
      stub :admin, :login => 'admin', :admin => true
    end
    
    model Status do
      stub :other_in_project, :message => 'other-in-project', :user => all_stubs(:other_user), :created_at => current_time - 47.hours, :project => all_stubs(:project)
    end
  end
  
  before do
    @status = statuses :default
  end
  
  it "allow status owner to edit" do
    @status.should be_editable_by(users(:default))
  end
  
  it "allow admin to edit" do
    @status.should be_editable_by(users(:admin))
  end
  
  it "allow project owner to edit" do
    statuses(:other_in_project).should be_editable_by(users(:default))
  end
  
  it "restrict other user from editing" do
    @status.should_not be_editable_by(users(:other))
  end
  
  it "restrict nil user from editing" do
    @status.should_not be_editable_by(nil)
  end
end

describe Status, "(filtering by date)" do
  define_models :copy => false do
    time 2007, 6, 30, 6

    model User do
      stub :login => 'bob'
      stub :other, :login => 'fred'
    end

    model Context do
      stub :name => "Foo", :permalink => 'foo', :user => all_stubs(:user)
    end

    model Membership do
      stub :user => all_stubs(:user), :context => all_stubs(:context), :project_id => 1
    end

    model Status do
      stub :message => 'default', :state => 'processed', :hours => 5, :created_at => current_time - 5.minutes, :user => all_stubs(:user), :project_id => 1
      stub :status_day, :message => 'status_day', :created_at => current_time - 8.minutes, :user => all_stubs(:other_user), :project_id => 2
      stub :status_week_1, :message => 'status_week_1', :created_at => current_time - 3.days
      stub :status_week_2, :message => 'status_week_2', :created_at => current_time - (4.days + 20.hours), :user => all_stubs(:other_user)
      stub :status_biweek_1, :message => 'status_biweek_1', :created_at => current_time - 8.days, :user => all_stubs(:other_user)
      stub :status_biweek_2, :message => 'status_biweek_2', :created_at => current_time - (14.days + 20.hours)
      stub :status_month_1, :message => 'status_month_1', :created_at => current_time - 20.days, :user => all_stubs(:other_user)
      stub :status_month_2, :message => 'status_month_2', :created_at => current_time - (28.days + 20.hours)
      stub :archive, :message => 'archive', :created_at => current_time - 35.days
      stub :uncounted, :message => 'uncounted', :created_at => current_time - 2.minutes, :project_id => nil
    end
  end
  
  before do
    @old = Time.zone
    Time.zone = -28800
    @user  = users :default
    @other = users :other
    @ctx   = contexts :default
  end
  
  after do
    Time.zone = @old
  end
  
  it "shows recent statuses with no filter" do
    compare_stubs :statuses, Status.filter(nil, nil)[0], [:uncounted, :default, :status_day, :status_week_1, :status_week_2,
      :status_biweek_1, :status_biweek_2, :status_month_1, :status_month_2, :archive]
  end
  
  it "counts recent status hours with no filter" do
    Status.filtered_hours(nil, nil).total.should == 9 * 5
    Status.hours(nil, nil).should == 9 * 5
  end
  
  it "shows recent statuses by user" do
    expected = [:uncounted, :default, :status_week_1,  :status_biweek_2, :status_month_2, :archive]
    compare_stubs :statuses, Status.filter(@user.id, nil)[0], expected
    compare_stubs :statuses, @user.statuses.filter(nil)[0],   expected
  end
  
  it "counts recent status hours by user with no filter" do
    Status.filtered_hours(@user.id, nil).total.should == 5 * 5
    Status.hours(@user.id, nil).should == 5 * 5
    @user.statuses.filtered_hours(nil).total.should   == 5 * 5
    @user.statuses.hours(nil).should   == 5 * 5
  end
  
  it "shows today's statuses" do
    compare_stubs :statuses, Status.filter(nil, :daily)[0], [:uncounted, :default, :status_day]
  end
  
  it "counts today's status hours" do
    Status.filtered_hours(nil, 'daily').total.should == 2 * 5
    Status.hours(nil, 'daily').should == 2 * 5
  end
  
  it "shows today's statuses by user" do
    expected = [:uncounted, :default]
    compare_stubs :statuses, Status.filter(@user.id, 'daily')[0], expected
    compare_stubs :statuses, @user.statuses.filter('daily')[0],   expected
  end
  
  it "counts today's status hours by user" do
    Status.filtered_hours(@user.id, 'daily').total.should == 5
    @user.statuses.filtered_hours('daily').total.should   == 5
    Status.hours(@user.id, 'daily').should == 5
    @user.statuses.hours('daily').should   == 5
  end
  
  it "shows this week's statuses" do
    compare_stubs :statuses, Status.filter(nil, 'weekly')[0], [:uncounted, :default, :status_day, :status_week_1, :status_week_2]
  end
  
  it "shows this week's statuses by context" do
    compare_stubs :statuses, Status.filter(nil, :weekly, :context => @ctx)[0], [:default, :status_week_1, :status_week_2]
  end
  
  it "counts this week's status hours" do
    Status.filtered_hours(nil, 'weekly').total.should == 4 * 5
    Status.hours(nil, 'weekly').should == 4 * 5
  end
  
  it "counts this week's status hours by context" do
    Status.filtered_hours(nil, 'weekly', :context => @ctx).total.should == 3 * 5
    Status.hours(nil, 'weekly', :context => @ctx).should == 3 * 5
  end
  
  it "shows this week's statuses by user" do
    expected = [:uncounted, :default, :status_week_1]
    compare_stubs :statuses, Status.filter(@user.id, 'weekly')[0], expected
    compare_stubs :statuses, @user.statuses.filter[0],             expected
  end
  
  it "counts this week's status hours by user" do
    Status.filtered_hours(@user.id, 'weekly').total.should == 2 * 5
    @user.statuses.filtered_hours('weekly').total.should   == 2 * 5
    Status.hours(@user.id, 'weekly').should == 2 * 5
    @user.statuses.hours('weekly').should   == 2 * 5
  end
  
  it "shows this fortnight's statuses" do
    compare_stubs :statuses, Status.filter(nil, 'bi-weekly')[0], [:uncounted, :default, :status_day, :status_week_1, :status_week_2, :status_biweek_1, :status_biweek_2]
  end
  
  it "counts this fortnight's status hours" do
    Status.filtered_hours(nil, 'bi-weekly').total.should == 6 * 5
    Status.hours(nil, 'bi-weekly').should == 6 * 5
  end
  
  it "shows this fortnight's statuses by user" do
    expected = [:uncounted, :default, :status_week_1, :status_biweek_2]
    compare_stubs :statuses, Status.filter(@user.id, 'bi-weekly')[0], expected
    compare_stubs :statuses, @user.statuses.filter('bi-weekly')[0],   expected
  end
  
  it "counts this fortnight's status hours by user" do
    Status.filtered_hours(@user.id, 'bi-weekly').total.should == 3 * 5
    @user.statuses.filtered_hours('bi-weekly').total.should   == 3 * 5
    Status.hours(@user.id, 'bi-weekly').should == 3 * 5
    @user.statuses.hours('bi-weekly').should   == 3 * 5
  end
  
  it "shows earlier fortnight's statuses" do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 14, 6))
    compare_stubs :statuses, Status.filter(nil, 'bi-weekly')[0], [:status_month_1, :status_month_2]
  end
  
  it "counts earlier fortnight's status hours" do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 14, 6))
    Status.filtered_hours(nil, 'bi-weekly').total.should == 2 * 5
    Status.hours(nil, 'bi-weekly').should == 2 * 5
  end
  
  it "shows earlier fortnight's statuses by user" do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 14, 6))
    expected = [:status_month_2]
    compare_stubs :statuses, Status.filter(@user.id, 'bi-weekly')[0], expected
    compare_stubs :statuses, @user.statuses.filter('bi-weekly')[0],   expected
  end
  
  it "counts earlier fortnights's status hours by user" do
    Time.stub!(:now).and_return(Time.utc(2007, 6, 14, 6))
    Status.filtered_hours(@user.id, 'bi-weekly').total.should == 5
    @user.statuses.filtered_hours('bi-weekly').total.should   == 5
    Status.hours(@user.id, 'bi-weekly').should == 5
    @user.statuses.hours('bi-weekly').should   == 5
  end
  
  it "shows this month's statuses" do
    compare_stubs :statuses, Status.filter(nil, 'monthly')[0],  [:uncounted, :default, :status_day, :status_week_1, :status_week_2, :status_biweek_1, :status_biweek_2, :status_month_1, :status_month_2]
  end
  
  it "counts this month's status hours" do
    Status.filtered_hours(nil, 'monthly').total.should == 8 * 5
    Status.hours(nil, 'monthly').should == 8 * 5
  end
  
  it "shows this month's statuses by user" do
    expected = [:uncounted, :default, :status_week_1, :status_biweek_2, :status_month_2]
    compare_stubs :statuses, Status.filter(@user.id, 'monthly')[0], expected
    compare_stubs :statuses, @user.statuses.filter('monthly')[0],   expected
  end
  
  it "counts this month's status hours by user" do
    Status.filtered_hours(@user.id, 'monthly').total.should == 4 * 5
    @user.statuses.filtered_hours('monthly').total.should   == 4 * 5
    Status.hours(@user.id, 'monthly').should == 4 * 5
    @user.statuses.hours('monthly').should   == 4 * 5
  end
end

describe_validations_for Status, :user_id => 1, :message => 'foo bar' do
  presence_of :user_id, :message
end