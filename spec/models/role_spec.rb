# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Role do
  describe "attributes" do
    it { should have_attribute(:name) }
  end

  describe 'associations' do
    it { should have_many(:student_sharings).dependent(:restrict)}
    it { should have_many(:users).dependent(:restrict)}
  end
  
  describe "With name" do 
    let(:admin) { FactoryGirl.create(:role, :name => "Admin")}
    let(:teacher) { FactoryGirl.create(:role, :name => "Teacher") }
    it "return list roles" do 
      rs = Role.with_name(:admin, :teacher)
      rs.count.should == 2
    end
    
    it "return empty list roles" do 
      rs = Role.with_name(:admin1, :teacher1)
      rs.count.should == 0
    end
  end 
    
  describe "Alias function [](name)" do 
    it "return existed role" do
      rs = Role.[]:admin  
      rs.name.should == "Admin"
    end
    
    it "return nil role object"do
      rs = Role.[]:student 
      rs.should be_nil
    end 
  end

  describe "clear caches" do 
    it "return empty caches" do 
      rs = Role.clear_caches 
      rs.should equal {}
      
    end 
  end 
end
