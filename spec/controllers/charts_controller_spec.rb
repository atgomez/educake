require 'spec_helper'

describe ChartsController do
  render_views
  
  let(:user) {FactoryGirl.create(:teacher)}
  let(:student) { 
    student = FactoryGirl.build(:student)
    student.teacher = user
    student.save!
    student
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
      # get 'goal_chart'
      # response.should be_success
      pending "test this case"
    end
  end

end
