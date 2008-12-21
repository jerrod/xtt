require File.dirname(__FILE__) + '/../spec_helper'

describe Campfire do
  before(:each) do
    @campfire = Campfire.new
  end

  it "should be valid" do
    @campfire.should be_valid
  end
end
