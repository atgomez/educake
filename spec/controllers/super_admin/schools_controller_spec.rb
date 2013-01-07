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
      response.should render_template("index")
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

  describe "POST create" do 
    it "successfully" do 
      attrs = {:name => "Nguyen An Ninh", :address1 => "123 nguyen an ninh", 
        :address2 => "124 nguyen an ninh", :city => "Hanoi", :state => "Alaska", 
        :zipcode => "1245", :phone => "1234567", 
        :admin_attributes => { :first_name => "aaa", :last_name => "bbb", :email => "test@gmail.com", :role_id => "1"}}

      post :create, :school => attrs
      response.should redirect_to super_admin_school_path(School.last)
    end
    it "unsuccessfully" do 
       attrs = {:name => "", :address1 => "123 nguyen an ninh", 
        :address2 => "124 nguyen an ninh", :city => "Hanoi", :state => "Alaska", 
        :zipcode => "1245", :phone => "1234567", 
        :admin_attributes => { :first_name => "aaa", :last_name => "bbb", :email => "test@gmail.com", :role_id => "1"}}
      post :create, :school => attrs
      response.should render_template("new")
    end 
  end 

  describe "PUT update" do 
    it "successfully" do 
      attrs = {:name => "Nguyen An Ninh1", 
        :admin_attributes => { :first_name => "test", :last_name => "name", :email => "testtest@gmail.com", :role_id => "1"}}
      put :update, :school => attrs, :id => school.id
      #response.should redirect_to super_admin_school_path(school)  
      response.should be_success    
    end

    it "unsuccessfully" do 
      put :update, :school => {:name => ""}, :id => school.id 
      response.should render_template("edit")
    end 
  end 
  describe "Delete destroy" do 
  	it "successfully" do 
  		delete :destroy, :id => school.id 
  		response.should redirect_to super_admin_schools_path
  	end 
  end 
end