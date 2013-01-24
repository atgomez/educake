require 'spec_helper'

describe "Goal API", :type => :feature do
  let(:client_application) { FactoryGirl.create(:client_application) }
  let(:user) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student, :teacher => user) }
  let(:oauth_consumer) do
    OAuth::Consumer.new(client_application.key, client_application.secret, {
      :site => "http://www.example.com",
      :scheme => :query_string,
      # :scheme => :header,
      :http_method => :post,
    })
  end
  let(:access_token) { FactoryGirl.create(:oauth2_token, :client_application => client_application, :user => user) }
 
  before(:each) do
    access_token
    20.times {FactoryGirl.create(:goal, :student => student)}
  end
 
  after do
    Capybara.reset_sessions!
  end

  describe "GET /api/v1/goals/:student_id" do
    let(:req_path) { "/api/v1/goals/#{student.id}" }

    context "OAuth1" do
      before do
        req = oauth_consumer.create_signed_request(:get, req_path, access_token)
        visit req.path
      end    

      it "returns data" do
        # puts page.body
        page.body.should_not be_blank
      end
    end

    context "OAuth2" do
      it "returns data" do
        get req_path, nil, {"HTTP_AUTHORIZATION" => "OAuth #{access_token.token}"}
        response.should be_success
      end
    end
  end

  describe "POST /api/v1/goals/:goal_id/add_grade" do
    let(:goal) {FactoryGirl.create(:goal, :student => student)}
    let(:req_path) { "/api/v1/goals/#{goal.id}/add_grade" }

    # context "OAuth1" do
    #   before do
    #     req = oauth_consumer.create_signed_request(:post, req_path, access_token)
    #     visit req.path
    #   end    

    #   it "returns data" do
    #     puts page.body
    #     page.body.should_not be_blank
    #   end
    # end

    context "OAuth2" do
      it "create the grade" do
        post req_path, {:accuracy => 10, :due_date => goal.baseline_date + 2.days}, 
                       {"HTTP_AUTHORIZATION" => "OAuth #{access_token.token}"}
        puts response.body
        response.should be_success
      end
    end
  end
end
