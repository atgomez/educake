require 'spec_helper'

describe ChartsController do

  describe "GET 'user_chart'" do
    it "returns http success" do
      get 'user_chart'
      response.should be_success
    end
  end

  describe "GET 'student_chart'" do
    it "returns http success" do
      get 'student_chart'
      response.should be_success
    end
  end

  describe "GET 'goal_chart'" do
    it "returns http success" do
      get 'goal_chart'
      response.should be_success
    end
  end

end