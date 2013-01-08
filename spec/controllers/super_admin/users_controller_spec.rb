require 'spec_helper'
describe SuperAdmin::UsersController do 
	render_views
  let(:super_admin) {FactoryGirl.create(:super_admin)}
  let(:school) {FactoryGirl.create(:school_with_admin)}
  let(:teacher) {FactoryGirl.create(:teacher, :school => school)}
  before(:each) do
    sign_in super_admin
  end

  describe "GET New" do 
  	it "successfully" do 
  		get :new, :school_id => school.id 
  		response.should render_template("new")
  	end 
  end 

  describe "POST create" do 
  	it "successfully" do 
      attrs = {:school_id => school.id, :first_name => "Jonh", :last_name => "Smith", 
      :role_id => "2", :email => "jonh@gmail.com", :phone => "123456789", :notes => "how are you?"}
      post :create, :user => attrs, :school_id => school.id, :back => "schools"
      response.should redirect_to(super_admin_school_path(User.last.school))
  	end 

    context "unsuccessfully" do 
      it "when invalid input" do
        attrs = {:school_id => school.id, :first_name => "", :last_name => "Smith", 
        :role_id => "2", :email => "jonh@gmail.com", :phone => "123456789", :notes => "how are you?"}
        post :create, :user => attrs, :school_id => school.id, :back => "schools"
        response.should render_template("new")
      end 
      it "when unexisted school" do 
        attrs = {:school_id => 0, :first_name => "", :last_name => "Smith", 
        :role_id => "2", :email => "jonh@gmail.com", :phone => "123456789", :notes => "how are you?"}
        post :create, :user => attrs, :school_id => school.id, :back => "schools"
        response.should render_template("edit")
      end 
    end 
  end 

  describe "GET edit" do 
  	it "successfully" do 
  		get :edit, :school_id => school.id, :id => teacher.id
  		response.should render_template("edit")
  	end 
  end 

  describe "PUT update" do 
    it "successfully" do 
      attrs = {:school_id => teacher.school.id, :first_name => "aaa", :last_name => "Smith", 
        :role_id => "2", :email => "jonh@gmail.com", :phone => "123456789", :notes => "how are you?"}
      put :update, :id => teacher.id, :user => attrs, :school_id => school.id, :back => "schools"
      response.should redirect_to(super_admin_school_path(teacher.school))
    end 
    it "unsuccessfully" do 
      attrs = {:school_id => teacher.school.id, :first_name => "", :last_name => "Smith", 
        :role_id => "2", :email => "jonh@gmail.com", :phone => "123456789", :notes => "how are you?"}
      put :update, :id => teacher.id, :user => attrs, :school_id => school.id, :back => "schools"
      response.should render_template("edit")
    end
  end 

  describe "PUT blocked account" do 
  	it "successfully" do 
  		put :blocked_account, :is_blocked => true, :id => teacher.id, :format => :js
  		response.should be_success
  	end 
  end

  describe "PUT reset password" do 
  	it "successfully" do 
    	put :reset_password, :id => teacher.id, :format => :js
  	  response.should be_success
    end
  end 

  describe "DELETE destroy" do   
  	it "successfully" do 
  		delete :destroy, :id => teacher.id 
  		sc = teacher.school
  		response.should redirect_to super_admin_school_path(sc)
  	end 
  end 

  describe "GET view as" do 
  	context "successfully" do 
  		it "with teacher role" do 
  			get :view_as, :id => teacher.id 
  			response.should redirect_to students_path(:user_id => teacher.id)
  		end
  		it "with admin role" do 
  			get :view_as, :id => school.admin.id 
  			response.should redirect_to admin_teachers_path(:admin_id => school.admin.id)
  		end 
  	end
  end 

  describe "GET search" do 
  	context "successfully" do 
  		context "search info for all school" do 
	  		it "search type is school" do 
	  			get "search_result", :query => "Admin", :school => school.id, :search_type => User::SCHOOL 
	  			response.should render_template("search_result")
	  		end
	  		it "search type is role" do 
	  			get :search_result, :query => "Admin", :school => school.id, :search_type => User::ROLE
	  			response.should render_template("search_result")
	  		end 
	  		it "search for admin name" do 
	  			get :search_result, :query => "test", :school => school.id 
	  			response.should render_template("search_result")
	  		end 
	  	end 


	  	context "search info for a school" do 
	  		it "search type is school" do 
	  			get "search_result", :query => "Admin", :school => school.id, :search_type => User::SCHOOL 
	  			response.should render_template("search_result")
	  		end
	  		it "search type is role" do 
	  			get :search_result, :query => "Admin", :school => school.id, :search_type => User::ROLE
	  			response.should render_template("search_result")
	  		end 
	  		it "search for user name" do 
	  			get :search_result, :query => "test", :school => school.id 
	  			response.should render_template("search_result")
	  		end 
	  	end 

  	end 

  end 
end 