require File.dirname(__FILE__) + '/../spec_helper'

[User, Project].each do |model|
  describe model, "#statuses" do
    define_models :statuses
  
    before do
      @record = send(model.table_name, :default)
    end
  
    it "retrieves status after given status" do
      @record.statuses.after(statuses(:default)).should == statuses(:in_project)
    end
    
    it "retrieves status before given status" do
      @record.statuses.before(statuses(:pending)).should == statuses(:in_project)
    end
  end
end

describe User, "(order)" do
  define_models do
    model Status do
      stub :pending, :state => 'pending', :hours => 0, :created_at => current_time - 3.days, :project => all_stubs(:project)
    end
  end
  
  it "retrieves user statuses in reverse-chronological order" do
    users(:default).statuses.should == [statuses(:in_project), statuses(:default), statuses(:pending)]
  end
  
  it "retrieves project statuses in reverse-chronological order" do
    projects(:default).statuses.should == [statuses(:in_project), statuses(:pending)]
  end
end