ActionController::Routing::Routes.draw do |map|
  status_filters = /weekly|bi-weekly|monthly|daily|bi\-weekly/

  map.root :controller => 'users', :action => 'index'

  map.resources :helps, :controller => "help"
  map.resources :statuses, :collection => { 'import' => :get }
  map.resources :projects, :member     => { :invite => :post }
  map.resources :contexts, :notifies, :tendrils
  
  map.filtered_user 'users/:id/:filter', :filter => status_filters, :controller => 'users', :action => 'show'
  
  map.with_options :controller => 'contexts', :action => 'show' do |context|
    context.context_for_all           'contexts/:id/all'
    context.context_for_me            'contexts/:id/:user_id', :user_id => /me/
    context.context_for_user          'contexts/:id/users/:user_id'
    context.filtered_context_for_all  'contexts/:id/all/:filter',      :filter => status_filters
    context.filtered_context_for_me   'contexts/:id/:user_id/:filter', :filter => status_filters, :user_id => /me/
    context.filtered_context_for_user 'contexts/:id/:user_id/:filter', :filter => status_filters
    context.formatted_filtered_context_for_all  'contexts/:id/all/:filter.:format',      :filter => status_filters
    context.formatted_filtered_context_for_me   'contexts/:id/:user_id/:filter.:format', :filter => status_filters, :user_id => /me/
    context.formatted_filtered_context_for_user 'contexts/:id/:user_id/:filter.:format', :filter => status_filters
  end
  
  map.with_options :controller => 'projects', :action => 'show' do |project|
    project.project_for_all           'projects/:id/all'
    project.project_for_me            'projects/:id/:user_id', :user_id => /me/
    project.project_for_user          'projects/:id/users/:user_id'
    project.filtered_project_for_all  'projects/:id/all/:filter',            :filter => status_filters
    project.filtered_project_for_me   'projects/:id/:user_id/:filter',       :filter => status_filters, :user_id => /me/
    project.filtered_project_for_user 'projects/:id/users/:user_id/:filter', :filter => status_filters
    project.formatted_filtered_project_for_all  'projects/:id/all/:filter.:format',            :filter => status_filters
    project.formatted_filtered_project_for_me   'projects/:id/:user_id/:filter.:format',       :filter => status_filters, :user_id => /me/
    project.formatted_filtered_project_for_user 'projects/:id/users/:user_id/:filter.:format', :filter => status_filters
  end
  
  map.resources :feeds # todo: move to projects
  
  map.resources :memberships  
  map.resources :users, :member => { :suspend   => :put,
                                     :unsuspend => :put,
                                     :purge     => :delete }, :collection => { :reset_password => :post }

  map.filtered_user 'users/:id/:filter', :filter => status_filters, :controller => 'users', :action => 'show'

  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :session, :settings

  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate', :activation_code => nil
  map.signup   '/signup',                    :controller => 'users',    :action => 'new'
  map.invite   '/invitations/:code',         :controller => 'users',    :action => 'invite'
  map.connect  '/invitations',               :controller => 'sessions', :action => 'new'
  map.login    '/login',                     :controller => 'sessions', :action => 'new'
  map.denied   '/access_denied',             :controller => 'sessions', :action => 'access_denied'
  map.logout   '/logout',                    :controller => 'sessions', :action => 'destroy'
end
