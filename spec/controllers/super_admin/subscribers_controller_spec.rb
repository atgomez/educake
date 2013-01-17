require 'spec_helper'
describe SuperAdmin::SubscribersController do
  render_views
  let(:super_admin) {FactoryGirl.create(:super_admin)}
  let(:subscriber) {FactoryGirl.create(:subscriber)}
  before(:each) do
    sign_in super_admin
  end

  describe "GET index" do
    it "assigns all subscribers as @subscribers" do
    	subscriber
      subscribers = Subscriber.load_data({})
      get :index, :format => :html
      assigns(:subscribers).all.should eq(subscribers.all)
      response.should render_template("index")
    end
    it "render view index" do
      get :index, :format => :html
      response.should render_template("index")
    end
  end


  describe "GET contact" do 
  	it "successfully" do 
  		get :contact, :id => subscriber.id, :format => :js
  		response.should  render_template("list_subscribers")
  	end
  end
end