ModelStubbing.define_models do
  time 2007, 6, 15, 6

  model User do
    stub :login => 'normal-user', :email => 'normal-user@example.com', :state => 'active',
      :salt => '7e3041ebc2fc05a40c60028e2c4901a81035d3cd', :crypted_password => '00742970dc9e6319f8019fd54864d3ea740f04b1',
      :created_at => current_time - 5.days, :remember_token => 'foo-bar', :remember_token_expires_at => current_time + 5.days,
      :activation_code => '8f24789ae988411ccf33ab0c30fe9106fab32e9b', :activated_at => current_time - 4.days, :time_zone => "UTC",
      :permalink => 'normal-user'
  end
  
  model Project do
    stub :name => 'project', :user => all_stubs(:user), :code => 'abc', :permalink => 'project'
    stub :another, :name => 'another', :code => 'def', :permalink => 'another'
  end
  
  model Status do
    stub :user => all_stubs(:user), :message => 'default', :state => 'processed', :hours => 5, :created_at => current_time - 2.days
    stub :in_project, :message => '@abc in-project', :created_at => current_time - 47.hours, :project => all_stubs(:project)
  end
  
  model Invitation do
    stub :code => 'abc', :email => 'invited-user@example.com', :project_ids => '55'
  end
  
  model Membership
  
  model Context

  model Campfire do
    stub :domain => "hoover"
  end
  
  model Tendril do
    stub :notifies_type => "Campfire", :notifies_id => 1, :project => all_stubs(:project)
  end
  
  model Help do
    stub :name => "foo"
    stub :foo, :name => "bar"
  end
end

ModelStubbing.define_models :feeds do
  model Feed do
    stub :name => 'my feed', :url => 'http://foo.bar', :project => all_stubs(:project)
    stub :lh, :name => 'lighthouse', :url => 'http://foo.lighthouseapp.com', :project => all_stubs(:project)
  end
end

ModelStubbing.define_models :users do
  model User do
    stub :admin,     :login => 'admin-user',     :permalink => 'admin-user',     :email => 'admin-user@example.com', :remember_token => 'blah', :admin => true
    stub :pending,   :login => 'pending-user',   :permalink => 'pending-user',   :email => 'pending-user@example.com',   :state => 'pending', :activated_at => nil, :remember_token => 'asdf', :activation_code => 'abcdef'
    stub :suspended, :login => 'suspended-user', :permalink => 'suspended-user', :email => 'suspended-user@example.com', :state => 'suspended', :remember_token => 'dfdfd'
    stub :nonmember, :login => 'nonmember',      :permalink => 'nonmember',      :email => 'nonmember@example.com'
  end
  
  model Project do
    stub :user, :user => all_stubs(:pending_user), :permalink => 'w00t', :name => "W00t"
  end
  
  model Membership do
    stub :user => all_stubs(:user), :project => all_stubs(:project), :code => 'abc'
    stub :admin, :user => all_stubs(:admin_user), :code => 'abc'
  end

  model Feed do
    stub :name => 'my feed', :url => 'http://foo.bar', :project => all_stubs(:project)
    stub :lh, :name => 'lighthouse', :url => 'http://foo.lighthouseapp.com', :project => all_stubs(:project)
  end

end

ModelStubbing.define_models :statuses do
  model Status do
    stub :pending, :state => 'pending', :message => '@abc pending', :hours => 0, :created_at => current_time - 5.hours, :project => all_stubs(:project)
  end

  model Membership do
    stub :user => all_stubs(:user), :project => all_stubs(:project), :code => 'abc'
    stub :another, :user => all_stubs(:user), :project => all_stubs(:another_project), :code => 'def'
  end
end

ModelStubbing.define_models :contexts do
  model Project do
    stub :etc, :name => "ETC", :permalink => 'etc'
  end

  model Context do
    stub :user => all_stubs(:user), :name => 'Woo', :permalink => 'woo'
  end

  model Membership do
    stub :code => 'etc', :user => all_stubs(:user), :project => all_stubs(:etc_project)
    stub :context, :project => all_stubs(:project), :context => all_stubs(:context), :code => 'default'
    stub :another, :project => all_stubs(:another_project), :context => all_stubs(:context), :code => 'another'
  end
end

ModelStubbing.define_models :stubbed, :insert => false