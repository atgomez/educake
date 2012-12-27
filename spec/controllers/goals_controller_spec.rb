require 'spec_helper'

describe GoalsController do
  render_views
  let(:user) {FactoryGirl.create(:teacher)}
  before(:each) do
    sign_in user
  end
  let(:student) { FactoryGirl.create(:student)}
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
                       :student => student)
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
  		attrs = build_goal.attributes.except("created_at", "updated_at")
  		post  :create, :goal => attrs
  		response.should_not be_success 
  		body = JSON.parse(response.body)
  		body["message"].should be_eql(I18n.t("goal.save_failed"))
  	end 
  end

  describe "Put Update Goal" do 
  	it "when not found student" do 
  		put "update", :id => goal.id, :goal => {:student_id => 0}
  		response.should_not be_success 
  		body = JSON.parse(response.body)
	   	body.should include("message" => I18n.t("student.student_not_found"))
  	end
  	it "when updating successfully" do
      put "update", :id => goal.id, :goal => {:student_id => goal.student.id, :description =>  "test"}
      response.should be_success 
      body = JSON.parse(response.body)
      body.should include("message" => I18n.t("goal.updated_successfully"))
  	end 
  	it "when updating unsuccessfully" do
      put "update", :id => goal.id, :goal => {:student_id => goal.student.id, :due_date => "dsds"}
      response.should_not be_success 
      body = JSON.parse(response.body)
      body.should include("message" => I18n.t("goal.save_failed"))
  	end

    it "when goal not found" do
      put :update, :id => 0, :goal => {:student_id => goal.student.id}
      response.should_not be_success
      body = JSON.parse(response.body) 
      body["message"].should be_eql(I18n.t("goal.not_found"))
    end  
  end 

  describe "Get New Grade" do 
  	it "when existed student" do 
  		get :new_grade, :student_id => student.id, :format => :js 
  		response.should be_success
  	end
    it "when unexisted student" do 
      get :new_grade, :student_id => 0, :format => :js 
      response.should be_success 
    end 
  end 

  describe "POST Add grade" do
    let(:grade) {FactoryGirl.create(:grade, :due_date => Date.today.strftime("%m-%d-%Y"),
    :accuracy => 20.0, 
    :goal => goal)}

    let(:build_grade) {FactoryGirl.build(:grade, :due_date => Date.today.strftime("%m-%d-%Y"),
    :accuracy => 20.0, 
    :goal => goal)}

    it "when existed goal, but invalid grade" do
      attrs = grade.attributes.except("id", "progress_id", "ideal_value", "created_at", "updated_at")
      attrs[:due_date] = "dfdfdf"
      post :add_grade, :grade => attrs , :student_id => student.id
      response.should_not be_success
      body = JSON.parse(response.body)
      body["message"].should be_eql(I18n.t("grade.save_failed"))
    end

    it "when existed goal, and create grade for it successfully" do 
      attrs = build_grade.attributes.except("id", "progress_id", "ideal_value", "created_at", "updated_at")
      attrs[:due_date] = Date.today.strftime("%m-%d-%Y")
      post :add_grade, :grade => attrs , :student_id => student.id
      response.should be_success
      body = JSON.parse(response.body)
      body["message"].should be_eql(I18n.t("grade.created_successfully"))
    end

    it "when existed goal, and create new grade unsuccessfully" do
      attrs = build_grade.attributes.except("id", "progress_id", "ideal_value", "created_at", "updated_at")
      attrs[:due_date] = "01-01-2012"
      post :add_grade, :grade => attrs , :student_id => student.id
      response.should_not be_success
      body = JSON.parse(response.body)
      body["message"].should be_eql(I18n.t("grade.save_failed"))
    end
    
    it "when unexisted goal, create grade unsuccessfully" do
      attrs = build_grade.attributes.except("id", "progress_id", "ideal_value", "created_at", "updated_at")
      attrs[:due_date] = Date.today.strftime("%m-%d-%Y")
      attrs[:goal_id] = nil
      post :add_grade, :grade => attrs , :student_id => student.id
      response.should_not be_success
      body = JSON.parse(response.body)
      body["message"].should be_eql(I18n.t("grade.save_failed"))
    end
  end

  describe "PUT Update grade" do 
    it "successfully" do
      put :update_grade, :id => goal.id, :grade => true
      response.should be_success
      body = JSON.parse(response.body)
      body["message"].should be_eql(I18n.t("goal.updated_successfully"))
    end 
    it "unsuccessfully" do 
      put :update_grade, :id => 0, :grade => true
      response.should_not be_success
      body = JSON.parse(response.body)
      body["message"].should be_eql(I18n.t("goal.save_failed"))
    end
  end 

  describe "Get Initial import grades" do 
    it "return popup" do 
      get :initial_import_grades, :student_id => student.id, :format => :js
      response.should be_success
    end
  end 
  # Need to refactor code to test all case
  # Now check fail case on client side
  describe "PUT import grades" do 
    it "successfully" do 
      put :import_grades, :student_id => student.id, :goal => {:id => goal.id,
       :grades => fixture_file_upload("/files/CSV 1-Table 1.csv", "text/csv")}, :format => :js
      response.should be_success
    end
    context "unsuccessfully" do 
      it "for wrong format file" do 
        put :import_grades, :student_id => student.id, :goal => {:id => goal.id,
         :grades => fixture_file_upload("/files/data.txt", "text/csv")}, :format => :js
        response.should be_success
      end
    end
  end 

  describe "Delete destroy" do
    context "successfully" do 
      it "when having student_id" do 
        delete :destroy, :id => goal.id, :student_id  => student.id
        response.should redirect_to(edit_student_path(student.id))
      end

      it "when student_id blank" do 
        delete :destroy, :id => goal.id
        response.should redirect_to(students_path)
      end

      it "when having redirect link" do 
        delete :destroy, :id => goal.id, :redirect_link => students_path
        response.should redirect_to(students_path)
      end
    end

    context "unsuccessfully" do 
      it "when goal is not found" do 
        delete :destroy, :id => 0, :student_id  => student.id
        response.should_not be_success
      end

      # it "when can not destroy" do 
      #   delete :destroy, :id => 0, :student_id  => student.id
      #   response.should_not be_success
      # end
    end 
  end

  describe "Get loads grades" do
    it "successfully" do 
       get :load_grades, :goal_id => goal.id
       response.should be_success
    end
  end
end