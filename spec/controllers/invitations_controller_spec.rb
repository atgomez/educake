require 'spec_helper'

describe InvitationsController do
  render_views
  let(:user) {FactoryGirl.create(:teacher)}
  before(:each) do
    sign_in user
  end
  let(:student) {FactoryGirl.create(:student)}
  let(:invitation) {FactoryGirl.build(:student_sharing, :student => student)}
  describe "Get New" do 
  	it "for object invitation" do 
  		get :new, :format => :js
  		response.should be_success
  	end 
  end 

  describe "POST create" do
  	it "successfully " do 
  		attrs = invitation.attributes.except("created_at", "updated_at")
  		put :create, :student_sharing => attrs, :format => :js
  		response.should be_success
  	end 
  end

  describe "Get edit" do 
  	it "for object invitation" do 
  		invitation.save
  		get :edit, :id => invitation.id, :format => :js
  		response.should be_success 
  	end 
  end

  describe "Put update" do 
  	it "successfully" do
  		invitation.save
  		attrs = invitation.attributes.except("created_at", "updated_at")
  		put :update, :id => invitation.id, :student_sharing => attrs, :format => :js
  		response.should be_success
  	end
  end

  describe "Delete destroy" do  
  	it "successfully" do 
  		invitation.save
  		delete :destroy, :id => invitation.id, :format => :js
  		response.should be_success
  	end
  end 

end