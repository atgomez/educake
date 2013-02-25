require 'spec_helper'

describe ProfileController do
  render_views
  let(:user) {FactoryGirl.create(:teacher)}
  before(:each) do
    sign_in user
  end

  describe "Get show" do 
  	it "return current user" do 
  		get :show, :id => user.id 
  		response.should be_success
  	end 
  end

  describe "Post change password" do 
  	it "successfully" do 
  		post :change_password, :user => {:current_password => "123456",
  			:password => "123123", :password_confirmation => "123123"}
  		response.should be_success
  		body = JSON.parse(response.body)
  		body["status"].should be_eql("ok")	
  	end
  	context "unsuccessfully" do 
  		it "when inputting current password" do 
	  		post :change_password, :user => {:current_password => "abcdef",
	  			:password => "123123", :password_confirmation => "123123"}
	  		response.should_not be_success
	  		body = JSON.parse(response.body)
	  		body["status"].should be_eql("error")	
  	  end

  	  it "when can not change password" do 
	  		post :change_password, :user => {}
	  		response.should_not be_success
	  		body = JSON.parse(response.body)
	  		body["message"].should be_eql(I18n.t("profile.change_password_fail"))	
  	  end
  	end
  end
end