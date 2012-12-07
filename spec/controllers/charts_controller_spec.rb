require 'spec_helper'

describe ChartsController do
  render_views
  
  let(:curriculum) {FactoryGirl.create(:curriculum)}
  let(:subject) {FactoryGirl.create(:subject)}
  let(:user) {FactoryGirl.create(:teacher)}
  let(:student) { FactoryGirl.create(:student, :teacher => user)  }

  let(:goal) {
    goal = FactoryGirl.build(:goal)
    goal.student = student
    goal.curriculum = curriculum
    goal.subject = subject
    goal.save!
    goal
  }

  before(:each) do
    sign_in user
  end

  describe "GET 'user_chart'" do
    it "returns http success" do
      get 'user_chart', :user_id => user.id
      response.should be_success
    end
  end

  describe "GET 'student_chart'" do
    it "returns http success" do
      get 'student_chart', :user_id => user.id, :student_id => student.id
      response.should be_success
    end
  end

  describe "GET 'goal_chart'" do
    it "returns http success" do
      get 'goal_chart', :user_id => user.id, :goal_id => goal.id
      response.should be_success
    end
  end

end
