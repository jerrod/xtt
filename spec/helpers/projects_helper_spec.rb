require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsHelper do
  {0.5 => 10, 1 => 10, 3 => 10, 10.5 => 20, 15 => 20}.each do |max, normalized|
    it "#normalized_max([#{max}]).should == #{normalized}" do
      normalized_max([max]).should == normalized
    end
  end
end