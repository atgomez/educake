require 'spec_helper'

describe Admin::TeachersController do
  render_views
  let(:admin) {FactoryGirl.create(:admin)}

  describe "GET 'index'" do
    subject { get :index }
    let(:unauthorized_user) {FactoryGirl.create(:teacher)}

    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in admin
      end

      it "returns the page" do
        subject.should render_template('index')
      end

      context "with teachers" do        
        let(:teacher1) {FactoryGirl.create(:teacher, :parent => admin)}
        let(:teacher2) {FactoryGirl.create(:teacher, :parent => admin)}
        let(:student) {FactoryGirl.create(:student, :teacher => teacher1)}
        let(:goal) {FactoryGirl.create(:goal_with_grades, :student => student)}

        before(:each) do
          teacher1
          teacher2
          goal
        end

        it "loads teachers and render the page" do
          subject.should render_template('index')
          assigns(:all_teachers).should_not be_blank
        end
      end
    end
  end

  describe "GET 'all'" do
    subject { get :all }

    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in admin
      end

      it "renders the page" do
        subject.should render_template('all')
        assigns(:teachers).should_not be_nil
      end
    end
  end

  describe "POST 'create'", :create => true do
    subject { post :create }
    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in admin
      end

      context "with valid request" do
        let(:params) {
          {
            :user => {
              :first_name => Faker::Name.first_name,
              :last_name => Faker::Name.last_name,
              :email => Faker::Internet.email
            }
          }
        }
        subject {
          post :create, params
        }

        it "creates the teacher and response result" do
          subject.should be_success
          assigns(:teacher).should_not be_nil
          ActionMailer::Base.deliveries.last.to.should == [params[:user][:email]]
        end
      end

      context "with invalid request" do
        let(:params) {
          {
            :user => {
              :first_name => Faker::Name.first_name,
              :last_name => Faker::Name.last_name
            }
          }
        }

        subject {
          post :create, params
        }

        it "returns the error" do
          subject.should_not be_success
        end
      end

      context "with unexpected error" do
        let(:params) {
          {:first_name => Faker::Name.first_name}
        }

        subject {
          post :create, params
        }

        it "returns the error" do
          User.should_receive(:new_with_role_name).and_raise(Exception.new("Fatal error!"))
          subject.should_not be_success
        end
      end
    end
  end

  describe "GET 'edit'", :edit => true do
    subject { get :edit, :id => "abc" }
    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in admin
      end

      context "with valid teacher" do
        let(:teacher) {FactoryGirl.create(:teacher, :parent => admin)}
        subject { get :edit, :id => teacher.id, :format => :js }

        it "returns the edit" do
          subject.should render_template("edit")
        end
      end

      context "with invalid teacher" do
        subject { get :edit, :id => "abc", :format => :js }

        it "returns the page" do
          subject.should_not be_success
        end
      end
    end
  end

  describe "PUT 'update'", :update => true do
    subject { put :update, :id => "abc" }
    include_examples "unauthorized"

    context "authorized" do
      let(:teacher) {FactoryGirl.create(:teacher, :parent => admin)}

      before(:each) do
        sign_in admin
      end

      context "with valid teacher" do
        let(:params) {
          {
            :user => {
              :first_name => Faker::Name.first_name,
              :last_name => Faker::Name.last_name,
              :email => Faker::Internet.email
            }
          }
        }        
        subject { put :update, params.merge(:id => teacher.id, :format => :js) }

        it "updates the teacher information" do
          subject.should be_success
          teacher = assigns(:teacher)
          params[:user].each do |k, v|
            teacher[k].should == v
          end
        end
      end

      context "with invalid teacher" do
        context "with unavailable teacher id" do
          subject { put :update, :id => "abc", :format => :js }

          it "renders 'page_not_found'" do
            subject.response_code.should == 404
          end
        end

        context "when updating failed" do
          subject { put :update, :id => teacher.id, :format => :js }

          it "returns the error" do
            User.any_instance.stub(:update_attributes).and_return(false)
            subject.should_not be_success
          end
        end

        context "with unexpected error" do
          subject { put :update, :id => teacher.id, :format => :js }

          it "returns the error" do
            User.any_instance.stub(:update_attributes).and_raise(Exception.new("Fatal error!"))
            subject.should_not be_success
          end
        end
      end
    end
  end

  describe "GET 'search'", :search => true do
    subject { get :search }
    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in admin
      end

      context "with query" do
        subject { get :search, :query => "abc" }

        it "searchs both teachers and students" do
          subject.should be_success
          assigns(:students).should_not be_nil
          assigns(:teachers).should_not be_nil
        end

        context "with 'teacher' type" do
          subject { get :search, :query => "abc", :type => 'teacher' }

          it "searchs only teachers" do
            subject.should be_success
            assigns(:students).should be_nil
            assigns(:teachers).should_not be_nil
          end
        end

        context "with 'student' type" do
          subject { get :search, :query => "abc", :type => 'student' }

          it "searchs only students" do
            subject.should be_success
            assigns(:students).should_not be_nil
            assigns(:teachers).should be_nil
          end
        end
      end

      context "without query" do
        subject { get :search }

        it "redirects to index page" do
          subject.should redirect_to(:action => 'index')
        end
      end
    end
  end

  describe "GET 'get_students'", :get_students => true do
    subject { get :get_students }
    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in admin
      end

      context "with valid teacher" do
        let(:teacher) {FactoryGirl.create(:teacher, :parent => admin)}
        subject { get :get_students, :teacher_id => teacher.id }

        it "returns the result" do
          subject.should be_success
          assigns(:students).should_not be_nil
        end
      end

      context "with invalid teacher" do
        subject { get :get_students, :teacher_id => "abc" }

         it "renders 'page_not_found'" do
          subject.response_code.should == 404
        end
      end
    end
  end

  describe "DELETE 'destroy'", :destroy => true do
    subject { delete :destroy, :id => "abc" }
    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in admin
      end
      let(:teacher) {FactoryGirl.create(:teacher, :parent => admin)}

      context "with valid teacher" do        
        subject { delete :destroy, :id => teacher.id }

        it "deletes the teacher and redirect to index" do
          id = teacher.id
          subject.response_code.should == 302
          _teacher = User.find_by_id(id)
          _teacher.should be_nil
        end
      end

      context "with invalid teacher" do
        subject { delete :destroy, :id => "abc" }

         it "renders 'page_not_found'" do
          subject.response_code.should == 404
        end
      end

      context "destroy failed" do
        subject { delete :destroy, :id => teacher.id }

        it "returns the error" do
          User.any_instance.stub(:destroy).and_return(false)
          subject.response_code.should == 302
          get :index
          response.body.should =~ /#{I18n.t("user.delete_failed")}/m
        end
      end
    end
  end

  context "viewed by super admin", :current => true do
    let(:super_admin) {FactoryGirl.create(:super_admin)}    
    before(:each) do
      sign_in super_admin
    end

    context "without 'user_id" do
      subject {get :edit, :id => "abc", :user_id => "abc", :admin_id => admin.id, :format => :js}
      it "renders 'page_not_found'" do
        subject.response_code.should == 404
      end
    end
  end
end