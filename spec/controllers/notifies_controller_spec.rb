require File.dirname(__FILE__) + '/../spec_helper'



describe NotifiesController, "GET #index" do
  define_models

  act! { get :index }

  before do
    @notifies = []
    login_as :default

    @user.campfires.stub!(:find).with(:all).and_return(@notifies)
  end

  it_assigns :notifies
  it_renders :template, :index

  describe NotifiesController, "(xml)" do
    define_models

    act! { get :index, :format => 'xml' }

    it_assigns :notifies
    it_renders :xml, :notifies
  end

  describe NotifiesController, "(json)" do
    define_models

    act! { get :index, :format => 'json' }

    it_assigns :notifies
    it_renders :json, :notifies
  end


end

describe NotifiesController, "GET #show" do
  define_models

  act! { get :show, :id => 1 }

  before do
    @notifies  = campfires(:default)
    login_as :default
    @user.campfires.stub!(:find).with('1').and_return(@notifies)
  end

  it_assigns :notifies
  it_renders :template, :show

  describe NotifiesController, "(xml)" do
    define_models

    act! { get :show, :id => 1, :format => 'xml' }

    it_renders :xml, :notifies
  end

  describe NotifiesController, "(json)" do
    define_models

    act! { get :show, :id => 1, :format => 'json' }

    it_renders :json, :notifies
  end


end

describe NotifiesController, "GET #new" do
  define_models
  act! { get :new }
  before do
    login_as :default
    @notifies  = @user.campfires.new
  end

  it "assigns @notifies" do
    act!
    assigns[:notifies].should be_new_record
  end

  it_renders :template, :new

  describe NotifiesController, "(xml)" do
    define_models
    act! { get :new, :format => 'xml' }

    it_renders :xml, :notifies
  end

  describe NotifiesController, "(json)" do
    define_models
    act! { get :new, :format => 'json' }

    it_renders :json, :notifies
  end


end

describe NotifiesController, "POST #create" do
  before do
    @attributes = {}
    @notifies = mock_model Campfire, :new_record? => false, :errors => []
    login_as :default
    @user.campfires.stub!(:new).with(@attributes).and_return(@notifies)
  end

  describe NotifiesController, "(successful creation)" do
    define_models
    act! { post :create, :notifies => @attributes }

    before do
      @notifies.stub!(:save).and_return(true)
    end

    it_assigns :notifies, :flash => { :notice => :not_nil }
    it_redirects_to { notify_path(@notifies) }
  end

  describe NotifiesController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :notifies => @attributes }

    before do
      @notifies.stub!(:save).and_return(false)
    end

    it_assigns :notifies
    it_renders :template, :new
  end

  describe NotifiesController, "(successful creation, xml)" do
    define_models
    act! { post :create, :notifies => @attributes, :format => 'xml' }

    before do
      @notifies.stub!(:save).and_return(true)
      @notifies.stub!(:to_xml).and_return("mocked content")
    end

    it_assigns :notifies, :headers => { :Location => lambda { notify_url(@notifies) } }
    it_renders :xml, :notifies, :status => :created
  end

  describe NotifiesController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :notifies => @attributes, :format => 'xml' }

    before do
      @notifies.stub!(:save).and_return(false)
    end

    it_assigns :notifies
    it_renders :xml, "notifies.errors", :status => :unprocessable_entity
  end

  describe NotifiesController, "(successful creation, json)" do
    define_models
    act! { post :create, :notifies => @attributes, :format => 'json' }

    before do
      @notifies.stub!(:save).and_return(true)
      @notifies.stub!(:to_json).and_return("mocked content")
    end

    it_assigns :notifies, :headers => { :Location => lambda { notify_url(@notifies) } }
    it_renders :json, :notifies, :status => :created
  end

  describe NotifiesController, "(unsuccessful creation, json)" do
    define_models
    act! { post :create, :notifies => @attributes, :format => 'json' }

    before do
      @notifies.stub!(:save).and_return(false)
    end

    it_assigns :notifies
    it_renders :json, "notifies.errors", :status => :unprocessable_entity
  end

end

describe NotifiesController, "GET #edit" do
  define_models
  act! { get :edit, :id => 1 }

  before do
    @notifies  = campfires(:default)
    login_as :default
    @user.campfires.stub!(:find).with('1').and_return(@notifies)
  end

  it_assigns :notifies
  it_renders :template, :edit
end

describe NotifiesController, "PUT #update" do
  before do
    @attributes = {}
    @notifies = campfires(:default)
    login_as :default
    @user.campfires.stub!(:find).with('1').and_return(@notifies)
  end

  describe NotifiesController, "(successful save)" do
    define_models
    act! { put :update, :id => 1, :notifies => @attributes }

    before do
      @notifies.stub!(:save).and_return(true)
    end

    it_assigns :notifies, :flash => { :notice => :not_nil }
    it_redirects_to { notify_path(@notifies) }
  end

  describe NotifiesController, "(unsuccessful save)" do
    define_models
    act! { put :update, :id => 1, :notifies => @attributes }

    before do
      @notifies.stub!(:save).and_return(false)
    end

    it_assigns :notifies
    it_renders :template, :edit
  end

  describe NotifiesController, "(successful save, xml)" do
    define_models
    act! { put :update, :id => 1, :notifies => @attributes, :format => 'xml' }

    before do
      @notifies.stub!(:save).and_return(true)
    end

    it_assigns :notifies
    it_renders :blank
  end

  describe NotifiesController, "(unsuccessful save, xml)" do
    define_models
    act! { put :update, :id => 1, :notifies => @attributes, :format => 'xml' }

    before do
      @notifies.stub!(:save).and_return(false)
    end

    it_assigns :notifies
    it_renders :xml, "notifies.errors", :status => :unprocessable_entity
  end

  describe NotifiesController, "(successful save, json)" do
    define_models
    act! { put :update, :id => 1, :notifies => @attributes, :format => 'json' }

    before do
      @notifies.stub!(:save).and_return(true)
    end

    it_assigns :notifies
    it_renders :blank
  end

  describe NotifiesController, "(unsuccessful save, json)" do
    define_models
    act! { put :update, :id => 1, :notifies => @attributes, :format => 'json' }

    before do
      @notifies.stub!(:save).and_return(false)
    end

    it_assigns :notifies
    it_renders :json, "notifies.errors", :status => :unprocessable_entity
  end

end

describe NotifiesController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }

  before do
    @notifies = campfires(:default)
    @notifies.stub!(:destroy)
    login_as :default
    @user.campfires.stub!(:find).with('1').and_return(@notifies)
  end

  it_assigns :notifies
  it_redirects_to { notifies_url }

  describe NotifiesController, "(xml)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :notifies
    it_renders :blank
  end

  describe NotifiesController, "(json)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'json' }

    it_assigns :notifies
    it_renders :blank
  end


end