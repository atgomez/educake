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
 
  let(:total_items) {40}

  before(:each) do
    access_token
    total_items.times {FactoryGirl.create(:goal, :student => student)}
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

      context "pagination", :pagination => true do
        it "returns the correct items number" do
          total = 0
          (total_items/20 + 1).times do |t|
            get req_path, {:page_id => t+1}, {"HTTP_AUTHORIZATION" => "OAuth #{access_token.token}"}
            response.should be_success
            info = JSON.parse(response.body)
            total += info['data'].length
          end

          total.should eq(total_items)
        end
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
      let(:due_date) {(goal.baseline_date + 2.days).strftime(I18n.t("date.formats.default"))}
      it "create the grade" do
        post req_path, {:accuracy => 10, :due_date => due_date}, 
                       {"HTTP_AUTHORIZATION" => "OAuth #{access_token.token}"}
        puts response.body
        response.should be_success
      end

      context "failure" do
        context "with invalid goal" do
          let(:req_path) { "/api/v1/goals/111233/add_grade" }

          it "returns 404 Not Found" do
            post req_path, {:accuracy => 10, :due_date => due_date}, 
                           {"HTTP_AUTHORIZATION" => "OAuth #{access_token.token}"}
            puts response.body
            response.response_code.should eq(404)
          end
        end

        context "with invalid param" do
          let(:due_date) {(goal.due_date + 2.days).strftime(I18n.t("date.formats.default"))}
          it "returns 404 Not Found" do
            post req_path, {:accuracy => 10, :due_date => due_date}, 
                           {"HTTP_AUTHORIZATION" => "OAuth #{access_token.token}"}
            puts response.body
            response.response_code.should eq(400)
          end
        end
      end
    end
  end
end
