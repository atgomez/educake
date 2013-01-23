require 'spec_helper'

describe "Students API", :type => :feature do
  let(:client_application) { FactoryGirl.create(:client_application) }
  let(:user) { FactoryGirl.create(:teacher) }
  let(:oauth_consumer) do
    OAuth::Consumer.new(client_application.key, client_application.secret, {
      :site => "http://www.example.com",
      # :scheme => :query_string,
      :scheme => :header,
      :http_method => :post,
    })
  end
  let(:access_token) { FactoryGirl.create(:oauth2_token, :client_application => client_application, :user => user) }
 
  before(:each) do
    access_token
  end
 
  after do
    Capybara.reset_sessions!
  end

  describe "GET /api/v1/students" do
    let(:req_path) { "/api/v1/students" }

    context "OAuth1" do
      before do
        req = oauth_consumer.create_signed_request(:get, req_path, access_token)
        visit req.path
      end    

      it "returns data" do
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
end
