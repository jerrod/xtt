require File.dirname(__FILE__) + '/../spec_helper'

describe_access_for StatusesController do
  all { define_models :users }
  
  # status owner and admin
  as :default, :admin do
    it_allows(:get,    :index)
    it_allows(:get,    :new)
    it_allows(:post,   :create)
    it_allows(:get,    :show)    { {:id => statuses(:default).id} }
    it_allows(:put,    :update)  { {:id => statuses(:default).id} }
    it_allows(:delete, :destroy) { {:id => statuses(:default).id} }
  end
  
  as :nonmember do
    it_allows(:get,       :index)
    it_allows(:get,       :new)
    it_allows(:post,      :create)
    it_restricts(:get,    :show)    { {:id => statuses(:default).id} }
    it_restricts(:put,    :update)  { {:id => statuses(:default).id} }
    it_restricts(:delete, :destroy) { {:id => statuses(:default).id} }
  end
  
  as :anon, :pending, :suspended do
    it_restricts(:get,  :index)
    it_restricts(:get,  :new)
    it_restricts(:post, :create)
    it_restricts(:get,    :show)    { {:id => statuses(:default).id} }
    it_restricts(:put,    :update)  { {:id => statuses(:default).id} }
    it_restricts(:delete, :destroy) { {:id => statuses(:default).id} }
  end
end