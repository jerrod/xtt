require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Project, :name => 'foo', :user_id => 32 do
  presence_of :name, :user_id
end

describe Project do
  define_models
  
  it "downcases Project#name to #code if empty" do
    p = Project.new :name => "FOO BAR-BAZ"
    p.valid?
    p.code.should == 'foobarbaz'
  end
  
  it "creates a membership for its owner on create" do
    p = Project.create(:name => "Test Project", :user => users(:default), :code => 'test')
    p.memberships.size.should == 1
    p.memberships.first.user.should == users(:default)
    p.memberships.first.code.should == 'test'
  end
  
  
end
