require File.dirname(__FILE__) + '/../spec_helper'

# USER SCOPE

describe StatusesController, "GET #index for user" do
  define_models

  act! { get :index, :format => 'xml' }

  before do
    @statuses = [statuses(:default)]
    login_as :default
    @user.stub!(:statuses).and_return(@statuses)
  end
  
  it_assigns :statuses
  it_renders :xml, :statuses
end

describe StatusesController, "GET #new" do
  define_models
  act! { get :new }
  before do
    @status  = Status.new
    controller.stub!(:login_required)
  end

  it "assigns @status" do
    act!
    assigns[:status].should be_new_record
  end
  
  it_renders :template, :new
  
  describe StatusesController, "(xml)" do
    define_models
    act! { get :new, :format => 'xml' }

    it_renders :xml, :status
  end
end

describe StatusesController, "POST #create" do
  before do
    @attributes = {:code_and_message => 'foo'}
    @status = Status.new(@attributes)
    controller.stub!(:login_required)
    login_as :default
    @user.stub!(:post).and_return(@status)
    @user.statuses.stub!(:before).and_return(nil)
    @status.user = @user
  end

  describe StatusesController, "(successful replace-creation with text field)" do
    define_models
    act! {
      post :create, { :replace => "created_datetime,finished_datetime,code_and_message\n2007-12-25 00:00:25,2007-12-25 00:00:35,monkey,stealing bananas", :confirm => "on", :confirm2 => "on" }
    }
    
    before do
      login_as :default
      controller.stub!(:login_required)
      @user.stub!(:backup_statuses!)
    end

    it "replaces status" do
      count = Status.count
      act!
      (Status.count - count).should == -1
    end
    
    it "backs up statuses" do
      @user.should_receive(:backup_statuses!)
      act!
    end

    it "uses the correct timezone" do
      @user.time_zone = -8
      act!
      @user.statuses(true)[0].created_at.utc.should == Time.mktime(2007,12,25,0,0,25)
    end
  end

  describe StatusesController, "(successful import-creation with text field" do
    define_models
    act! { post :create, { :import => "created_datetime,finished_datetime,code_and_message\n2007-12-25 00:00:25,2007-12-25 00:00:35,monkey,stealing bananas", :format => "html" } }
    
    it "creates a status" do
      count = Status.count
      act!
      (Status.count - count).should == 1
    end
  end
    
  describe StatusesController, "(successful creation)" do
    define_models
    act! { post :create, @params }
    
    before do
      @params = {:status => @attributes}
      @status.stub!(:new_record?).and_return(false)
    end
    
    it_assigns :status
    it_redirects_to { root_path }
    
    it "redirects to alternate path with destination parameter" do
      @params.update :destination => '/projects'
      acting.should redirect_to(projects_path)
    end
    
    it "ignores external destination parameter" do
      @params.update :destination => 'http://google.com'
      acting.should redirect_to(root_path)
    end
  end
  
  describe StatusesController, "(successful creation with OUT button)" do
    define_models
    act! { post :create, :status => @attributes, :submit => "Out" }
    
    before { @status.stub!(:new_record?).and_return(false) }
    
    it "defaults message to 'Out'" do
      @attributes[:code_and_message] = nil
      @user.should_receive(:post).with('Out').and_return(@status)
      act!
    end
    
    it "uses given message" do
      @attributes[:code_and_message] = "Blah"
      @user.should_receive(:post).with('Blah').and_return(@status)
      act!
    end
    
    it "strips project code and uses given message" do
      @attributes[:code_and_message] = "@foo Blah"
      @user.should_receive(:post).with('Blah').and_return(@status)
      act!
    end
  end

  describe StatusesController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :status => @attributes }

    before do
      @status.message = nil
      controller.stub!(:login_required)
    end
    
    it_assigns :status
    it_renders :template, :new
  end
  
  describe StatusesController, "(successful creation, xml)" do
    define_models
    act! { post :create, :status => @attributes, :format => 'xml' }

    before { @status.stub!(:new_record?).and_return(false) }
    
    it_assigns :status, :headers => { :Location => lambda { status_url(@status) } }
    it_renders :xml, :status, :status => :created
  end
  
  describe StatusesController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :status => @attributes, :format => 'xml' }

    before do
      @status.message = nil
      controller.stub!(:login_required)
    end
    
    it_assigns :status
    it_renders :xml, "status.errors", :status => :unprocessable_entity
  end
end

# GLOBAL SCOPE

describe StatusesController, "GET #show" do
  define_models

  act! { get :show, :id => 1 }

  before do
    @status  = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
    controller.stub!(:login_required)
  end
  
  it_assigns :status
  it_renders :template, :show
  
  describe StatusesController, "(xml)" do
    define_models
    
    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :status
  end
end

describe StatusesController, "PUT #update" do
  before do
    @attributes = {}
    @status = statuses(:default)
    Status.stub!(:find).with('1').and_return(@status)
    controller.stub!(:login_required)
  end
  
  describe StatusesController, "(successful save)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes }

    before do
      @status.stub!(:save).and_return(true)
    end
    
    it_assigns :status, :flash => { :notice => :not_nil }
    it_redirects_to { status_path(@status) }
  end

  describe StatusesController, "(unsuccessful save)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes }

    before do
      @status.stub!(:save).and_return(false)
    end
    
    it_assigns :status
    it_renders :template, :show
  end

  describe StatusesController, "(successful save, xml)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(true)
    end
    
    it_assigns :status
    it_renders :blank
  end
  
  describe StatusesController, "(unsuccessful save, xml)" do
    define_models
    act! { put :update, :id => 1, :status => @attributes, :format => 'xml' }

    before do
      @status.stub!(:save).and_return(false)
    end
    
    it_assigns :status
    it_renders :xml, "status.errors", :status => :unprocessable_entity
  end
end

describe StatusesController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }
  
  before do
    @status = statuses(:default)
    @status.stub!(:destroy)
    Status.stub!(:find).with('1').and_return(@status)
    controller.stub!(:login_required)
  end

  it_assigns :status
  it_redirects_to { statuses_path }
  
  describe StatusesController, "(xml)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :status
    it_renders :blank
  end
end