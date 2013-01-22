require 'spec_helper'

describe SubscribersController do

  def valid_attributes
    { "email" => "test@test.com" }
  end

  def valid_session
    {}
  end
  
  describe "GET new" do
    it "assigns a new subscriber as @subscriber" do
      get :new, {}, valid_session
      assigns(:subscriber).should be_a_new(Subscriber)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Subscriber" do
        expect {
          post :create, {:subscriber => valid_attributes}, valid_session
        }.to change(Subscriber, :count).by(1)
      end

      it "assigns a newly created subscriber as @subscriber" do
        post :create, {:subscriber => valid_attributes}, valid_session
        assigns(:subscriber).should be_a(Subscriber)
        assigns(:subscriber).should be_persisted
      end

      it "redirects to the created subscriber" do
        post :create, {:subscriber => valid_attributes}, valid_session
        response.should redirect_to(new_subscriber_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved subscriber as @subscriber" do
        # Trigger the behavior that occurs when invalid params are submitted
        Subscriber.any_instance.stub(:save).and_return(false)
        post :create, {:subscriber => { "email" => "invalid value" }}, valid_session
        assigns(:subscriber).should be_a_new(Subscriber)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Subscriber.any_instance.stub(:save).and_return(false)
        post :create, {:subscriber => { "email" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end
end
