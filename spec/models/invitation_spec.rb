require File.dirname(__FILE__) + '/../spec_helper'

describe_validations_for Invitation, :code => 'abc', :email => 'foo@bar.com' do
  presence_of :email
end