require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper, "#number_to_running_time" do
  { nil => '0', 
    0 => '0', 
    30 => '00:30', 
    100 => '01:40', 
    (37.minutes + 23) => '37:23', 
    (1.hour + 37.minutes + 23) => '1:37:23',
    -8.hours => '-8:00:00'
  }.each do |input, expected|
    it "shows correct running time for #{input.inspect} => #{expected.inspect}" do
      number_to_running_time(input).should == expected
    end
  end
end