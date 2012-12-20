require 'spec_helper'

describe ChartsController do
  render_views
  
  let(:curriculum) {FactoryGirl.create(:curriculum)}
  let(:subject) {FactoryGirl.create(:subject)}
  let(:user) {FactoryGirl.create(:teacher)}
  let(:student) { FactoryGirl.create(:student, :teacher => user)  }
  let(:goal) { 
    goal = FactoryGirl.create(:goal, 
                       :curriculum => curriculum, 
                       :subject => subject,
                       :student => student)
  }
  let(:progress_1) {
    FactoryGirl.build(:progress, :due_date => Date.parse('01/02/2013'), :accuracy => 45, :goal => goal)
  }

  let(:progress_2) {
    FactoryGirl.build(:progress, :due_date => Date.parse('01/05/2013'), :accuracy => 70, :goal => goal)
  }

  let(:progress_3) {
    FactoryGirl.build(:progress, :due_date => Date.parse('01/08/2013'), :accuracy => 80, :goal => goal)
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
    context "normal goal chart" do
      it "returns http success" do
        @goal = goal
        @goal.build_progresses
        @goal.progresses[0] = progress_1
        @goal.progresses[1] = progress_2
        @goal.progresses[2] = progress_3
        @goal.save
        get 'goal_chart', :user_id => user.id, :goal_id => @goal.id
        response.should be_success
      end
    end

    context "goal chart with specific color" do
      it "returns http success" do
        get 'goal_chart', :user_id => user.id, :goal_id => goal.id, :color => "4572A7"
        response.should be_success
      end
    end
  end

end
