require File.dirname(__FILE__) + '/../spec_helper'

describe TendrilsController, "POST #create" do
  before do
    @attributes = {}
    @tendril = mock_model Tendril, :new_record? => false, :errors => [], :notifies => mock_model(Campfire)
    login_as :default
    @user.tendrils.stub!(:new).with(@attributes).and_return(@tendril)
  end

  describe TendrilsController, "(successful creation)" do
    define_models
    act! { post :create, :tendril => @attributes }

    before do
      @tendril.stub!(:save).and_return(true)
    end

    it_assigns :tendril, :flash => { :notice => :not_nil }
    it_redirects_to { notify_path(@tendril.notifies) }
  end

  describe TendrilsController, "(unsuccessful creation)" do
    define_models
    act! { post :create, :tendril => @attributes }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :template, :new
  end

  describe TendrilsController, "(successful creation, xml)" do
    define_models
    act! { post :create, :tendril => @attributes, :format => 'xml' }

    before do
      @tendril.stub!(:save).and_return(true)
      @tendril.stub!(:to_xml).and_return("mocked content")
    end

    it_assigns :tendril, :headers => { :Location => lambda { notify_url(@tendril.notifies) } }
    it_renders :xml, :tendril, :status => :created
  end

  describe TendrilsController, "(unsuccessful creation, xml)" do
    define_models
    act! { post :create, :tendril => @attributes, :format => 'xml' }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :xml, "tendril.errors", :status => :unprocessable_entity
  end

  describe TendrilsController, "(successful creation, json)" do
    define_models
    act! { post :create, :tendril => @attributes, :format => 'json' }

    before do
      @tendril.stub!(:save).and_return(true)
      @tendril.stub!(:to_json).and_return("mocked content")
    end

    it_assigns :tendril, :headers => { :Location => lambda { notify_url(@tendril.notifies) } }
    it_renders :json, :tendril, :status => :created
  end

  describe TendrilsController, "(unsuccessful creation, json)" do
    define_models
    act! { post :create, :tendril => @attributes, :format => 'json' }

    before do
      @tendril.stub!(:save).and_return(false)
    end

    it_assigns :tendril
    it_renders :json, "tendril.errors", :status => :unprocessable_entity
  end

end

describe TendrilsController, "DELETE #destroy" do
  define_models
  act! { delete :destroy, :id => 1 }

  before do
    @tendril = tendrils(:default)
    @tendril.stub!(:destroy)
    login_as :default
    @user.tendrils.stub!(:find).with('1').and_return(@tendril)
  end

  it_assigns :tendril
  it_redirects_to { notify_url(@tendril.notifies) }

  describe TendrilsController, "(xml)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'xml' }

    it_assigns :tendril
    it_renders :blank
  end

  describe TendrilsController, "(json)" do
    define_models
    act! { delete :destroy, :id => 1, :format => 'json' }

    it_assigns :tendril
    it_renders :blank
  end


end