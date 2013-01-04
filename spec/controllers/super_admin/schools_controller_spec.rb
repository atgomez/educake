require 'spec_helper'
describe SuperAdmin::SchoolsController do
  render_views
  let(:super_admin) {FactoryGirl.create(:super_admin)}
  let(:school) {FactoryGirl.create(:school)}
  before(:each) do
    sign_in super_admin
  end
  describe "Get index" do 
  	it "successfully" do 
  		get :index
    end
  end

  describe "Get new" do 
  	it "successfully" do 
  		get :new 
  		response.should be_success
  	end
  end

  describe "Get edit" do 
  	it "successfully" do 
  		get :edit, :id => school.id 
  		response.should be_success
  	end
  end 

  describe "Delete destroy" do 
  	it "successfully" do 
  		delete :destroy, :id => school.id 
  		response.should redirect_to super_admin_schools_path
  	end 
  end 
end