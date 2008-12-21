require File.dirname(__FILE__) + '/../spec_helper'

describe StatusesHelper do
  before :all do
    @data = [
      [0, Time.utc(2008, 2, 4), 1],
      [0, Time.utc(2008, 2, 5), 2],
      [0, Time.utc(2008, 2, 7), 3],
      [0, Time.utc(2008, 2, 8), 4],
      [0, Time.utc(2008, 2, 9), 5]]
  end

  it "#chart_labels_for returns weekly labels" do
    chart_labels_for(:weekly, nil).should == %w(Mon Tue Wed Thu Fri Sat Sun)
  end

  it "#chart_labels_for returns monthly labels" do
    chart_labels_for(:monthly, (Time.utc(2008, 1, 1)..Time.utc(2008, 1, 5))).should == [1, 2, 3, 4, 5]
  end

  it "#chart_labels_for returns bi-weekly labels" do
    chart_labels_for(:'bi-weekly', (Time.utc(2008, 1, 29)..Time.utc(2008, 2, 2))).should == [29, 30, 31, 1, 2]
  end
  
  it "#chart_data_for returns weekly chart data" do
    chart_data_for(chart_labels_for(:weekly, nil), :weekly, @data).should == [1, 2, 0, 3, 4, 5, 0]
  end
  
  it "#chart_data_for returns monthly/bi-weekly chart data" do
    chart_data_for(chart_labels_for(:monthly, (Time.utc(2008, 2, 4)..Time.utc(2008, 2, 10))), :monthly, @data).should == [1, 2, 0, 3, 4, 5, 0]
  end
end