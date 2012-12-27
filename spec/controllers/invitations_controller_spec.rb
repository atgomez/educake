require 'spec_helper'

describe InvitationsController do
  render_views
  let(:user) {FactoryGirl.create(:teacher)}  
  let(:student) {FactoryGirl.create(:student, :teacher => user)}
  let(:invitation) {FactoryGirl.build(:student_sharing, :student => student)}
  before(:each) do
    sign_in user
  end

  describe "Get new", :current => true do 
  	it "for object invitation" do 
  		get :new, :student_id => student.id, :format => :js
  		response.should be_success
  	end 
  end 

  describe "POST create" do
  	it "successfully " do 
  		attrs = invitation.attributes.except("created_at", "updated_at")
  		put :create, :student_id => student.id, :student_sharing => attrs, :format => :js
  		response.should be_success
  	end 
  end

  describe "Get edit" do 
  	it "for object invitation" do 
  		invitation.save
  		get :edit, :student_id => student.id, :id => invitation.id, :format => :js
  		response.should be_success 
  	end 
  end

  describe "Put update" do 
  	it "successfully" do
  		invitation.save
  		attrs = invitation.attributes.except("created_at", "updated_at")
  		put :update, :student_id => student.id, :id => invitation.id, :student_sharing => attrs, :format => :js
  		response.should be_success
  	end
  end

  describe "Delete destroy" do  
  	it "successfully" do 
  		invitation.save
  		delete :destroy, :student_id => student.id, :id => invitation.id, :format => :js
  		response.should be_success
  	end
  end
end
