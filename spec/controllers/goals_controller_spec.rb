require 'spec_helper'

describe GoalsController do
  render_views
  let(:user) {FactoryGirl.create(:teacher)}
  before(:each) do
    sign_in user
  end
  let(:student) { FactoryGirl.create(:student)}
  let(:student1) { FactoryGirl.create(:student)}
  let(:curriculum) {FactoryGirl.create(:curriculum)}
  let(:subject) {FactoryGirl.create(:subject)}
  let(:curriculum1) {FactoryGirl.create(:curriculum)}
  let(:subject1) {FactoryGirl.create(:subject)}
  let(:goal) { 
    goal = FactoryGirl.create(:goal, 
                       :curriculum => curriculum, 
                       :subject => subject,
                       :student => student)
  }
  let(:build_goal) { 
    goal = FactoryGirl.build(:goal, 
    									 :baseline_date =>  "03-01-2012",
    									 :due_date  => "03-01-2013",
                       :curriculum => curriculum1, 
                       :subject => subject1,
                       :student => student1)
  }
  
  describe "Get New" do
  	it "return new goal" do
  		get 'new', :student_id => student.id, :format => :js
  		response.should be_success	
  	end
  end

  describe "Get Edit" do
  	it "return goal" do
  		get 'edit', :id => goal.id, :student_id => student.id, :format => :js
  		response.should be_success	
  	end
  end 

  describe "Post Create Goal" do 
  	it "when not found student" do 
	  	post "create", :goal => {"student_id" => 0}
	  	response.should_not be_success 
	  	body = JSON.parse(response.body)
	  	body.should include("message" => I18n.t("student.student_not_found"))
  	end

  	it "when creating successfully" do
  		attrs = build_goal.attributes.except("created_at", "updated_at", 
  			"grades_data_file_name", "grades_data_content_type", 
  			"grades_data_file_size", "grades_data_updated_at")
  		attrs['baseline_date'] = build_goal.baseline_date_string
  		attrs['due_date'] = build_goal.due_date_string
  		post  :create, :goal => attrs
  		response.should be_success 
  		body = JSON.parse(response.body)
  		body["message"].should be_eql(I18n.t("goal.created_successfully"))
  	end

  	it "when creating unsuccessfully" do
  		attrs = build_goal.attributes.except("created_at", "updated_at", 
  			"grades_data_file_name", "grades_data_content_type", 
  			"grades_data_file_size", "grades_data_updated_at")
  		post  :create, :goal => attrs
  		response.should_not be_success 
  		body = JSON.parse(response.body)
  		body["message"].should be_eql(I18n.t("goal.save_failed"))
  	end 
  end

  describe "Put Update Goal" do 
  	# it "when not found student" do 
  	# 	put "update", :goal => {:student_id => 0}
  	# 	response.should_not be_success 
  	# 	body = JSON.parse(response.body)
	  #  	body.should include("message" => I18n.t("student.student_not_found"))
  	# end
  	it "when updating successfully" do 
  	end 
  	it "when updating unsuccessfully" do 
  	end 
  end 

  describe "Get New Grade" do 
  	# it "new gade" do 
  	# 	get :new_grade, :format => :js 
  	# 	response.should be_success 
  	# end 
  end 
end