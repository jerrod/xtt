# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'rspec_on_rails_on_crack'
require 'model_stubbing'
require File.dirname(__FILE__) + "/model_stubs"
require 'ruby-debug'
Debugger.start

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    controller.stub!(:login_required)
    controller.stub!(:current_user).and_return(@user = user ? users(user) : :false)
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? "Basic #{Base64.encode64("#{users(user).login}:test")}" : nil
  end

  # TODO: Make a nifty rspec matcher
  def compare_stubs(model, actual, expected)
    expected.each do |e|
      a_index = actual.index(send(model, e))
      e_index = expected.index(e)
      if a_index.nil?
        fail "Record #{model}(#{e.inspect}) was not in the array, but should have been."
      else
        fail "Record #{model}(#{e.inspect}) is in wrong position: #{a_index.inspect} instead of #{e_index.inspect}" unless a_index == e_index
      end
    end
    
    actual.size.should == expected.size
  end
end

module RspecOnRailsOnCrack
  class ControllerAccessGroup
    def it_restricts(method, actions, params = {}, &block_params)
      it_performs :restricts, method, actions, block_params || params do
        route = controller.send(:logged_in?) ? :denied_path : :login_path
        response.should redirect_to(send(route, :to => request.request_uri))
      end
    end
  end
end
