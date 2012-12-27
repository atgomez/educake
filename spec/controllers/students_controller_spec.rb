require 'spec_helper'

describe StudentsController do
  render_views
  let(:user) {FactoryGirl.create(:teacher)}
  let(:admin) {FactoryGirl.create(:admin)}
  before(:each) do
    sign_in user
  end
  let(:student) {FactoryGirl.create(:student, :teacher_id => user.id)}
  let(:student_2) {FactoryGirl.create(:student)}  
  let(:build_student) {FactoryGirl.build(:student)}
  let(:sharing) {FactoryGirl.create(:student_sharing)}
  describe "Get index" do 
  	context "successfully" do 
	  	it "with js format" do
	  		get :index, :format => :js
	  		response.should be_success
	  	end

	  	it "with html format" do
	  		get :index, :format => :html
	  		response.should be_success
	  	end
	  end
  end 
  describe "Get show" do 
  	it "student in html format" do 
	  	get :show, :id => student.id, :format => :html
	  	response.should be_success
	  end

	  it "student in js format" do 
	  	get :show, :id => student.id, :format => :js
	  	response.should be_success
	  end

	  it "student does not exist" do 
	  	get :show, :id => student_2.id, :format => :html
	  	response.should_not be_success
	  end
  end 

  describe "Get new" do 
  	it "return student object for view" do 
  		get :new, :back_link => students_path
  		response.should be_success
  	end
  end

  describe "Get edit" do 
  	it "student in html format" do 
  		get :edit, :id => student.id
  		response.should be_success
  	end

  	it "student in js format" do 
  		get :edit, :id => student.id, :format => :js
  		response.should be_success
  	end 

  	it "student does not exist" do 
  		get :edit, :id => student_2.id
  		response.should_not be_success
  	end 
  end

  # describe "Post create" do 
  # 	it "successfully" do 
  # 		attrs = {:first_name => "aaaa", :last_name => "bbbb", :birthday => '01-02-2012'}
  # 		post :create, :student => attrs, :user_id => user.id,
  #          :back_link => students_path(:id => student, :user_id => user, :admin_id => admin),
  #          :format => :html
  # 		#response.should be_success
  #     st = Student.create attrs 
  #     response.should redirect_to(:action => 'edit', :id => st, :user_id => user, :admin_id => admin)
  # 	end 

  # 	it "unsuccessfully" do   
  # 		attrs = {:first_name => "", :last_name => "", :birthday => ""}
  # 		post :create, :student => attrs, :back_link => students_path
  # 		response.should_not be_success 
  # 	end 
  # end

  # describe "Put update" do
  # 	it "successfully" do 
  # 		attrs = {:first_name => "test", :last_name => "name", :birthday => '01-02-2012'}
  # 	  put :update, :id => student.id, :student => attrs
  # 		response.should be_success
  #   end

  #   context "unsuccessfully" do 
  #   	it "when update empty name" do
  #   		attrs = {:first_name => "", :last_name => ""}
  # 	  	put :update, :id => student.id, :student => attrs
  # 			response.should_not be_success
  #   	end 
  #   	it "when student does not found" do 
  #   		attrs = {:first_name => "adsafd", :last_name => "fdafd", :birthday => "01-02-2012"}
  # 	  	put :update, :id => student_2.id, :student => attrs
  # 			response.should_not be_success
  #   	end 
  #   end 
  # end 

  # describe "Delete destroy" do 
  #   it "successfully" do 
  #     delete :desstroy, :id => student.id 
  #     response.should be_success 
  #     response.should redirect_to(student_url)
  #   end
  # end

  describe "Get load grade" do 
    it "successfully" do 
      get :load_grade, :id => student.id, :format => :js 
      response.should be_success
    end
  end

  describe "Get load users" do
    it "successfully" do  
      get :load_users, :id => student.id, :format => :js
      response.should be_success
    end
  end
  # describe "Get search user" do 
  # 	it "was found out in users table" do 
  # 		get :search_user, :email => user.email, :format => :json
  # 		response.should be_success 
  # 	end

  # 	it "was found out in sharing table" do 
  # 		get :search_user, :email => sharing.email, :format => :json
  # 		response.should be_success 
  # 	end 
  #   it "was unxisted" do 
  #     get :search_user, :email => "test@gmail.com", :format => :json 
  #     response.should be_success
  #   end
  # end 

  describe "Get all students" do         
  	it "successfully" do 
  		get :all_students 
  		response.should be_success
  	end 
 	end 

end