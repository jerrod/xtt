require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for UsersController do
  all { define_models :users }

  as :anon, :default, :pending, :suspended do
    it_allows :get, :new
    it_allows :post, :create
    it_restricts(:put,    [:suspend, :unsuspend]) { { :id => users(:default).to_param } }
    it_restricts(:delete, [:destroy, :purge])     { { :id => users(:default).to_param } }
    it_allows :get, :activate, :key => 'foo'
  end
  
  as :anon do
    it_restricts :get, :index
    it_restricts(:get, [:show, :edit]) { { :id => users(:default).to_param } }
  end
  
  as :default do
    it_allows :get, :index
    it_allows(:get, [:show, :edit]) { { :id => users(:default).to_param } }
    it_allows(:get, :show)          { { :id => users(:admin).to_param   } }
    it_restricts(:get, :edit)       { { :id => users(:admin).to_param   } }
    it_restricts(:put, :update)     { { :id => users(:admin).to_param   } }
    it_restricts(:get, :show)       { { :id => users(:pending).to_param } }
  end
  
  as :admin do
    it_allows :get, [:index, :new]
    it_allows :post, :create
    it_allows(:put,    [:suspend, :unsuspend]) { { :id => users(:default).to_param } }
    it_allows(:delete, [:destroy, :purge])     { { :id => users(:default).to_param } }
    it_allows :get, :activate, :key => 'foo'
  end
end