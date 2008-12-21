require File.dirname(__FILE__) + '/../spec_helper'

describe Tendril do
  before(:each) do
    @tendril = Tendril.new
  end

  it "should be valid" do
    @tendril.should be_valid
  end
end
