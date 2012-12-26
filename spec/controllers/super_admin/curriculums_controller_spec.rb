require 'spec_helper'

describe SuperAdmin::CurriculumsController do
  render_views
  let(:super_admin) {FactoryGirl.create(:super_admin)}
  let(:curriculum) {FactoryGirl.create(:curriculum)}

  describe "GET 'index'" do
    subject { get :index }
    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in super_admin
      end

      it "returns the page" do
        subject.should render_template('index')
      end

      Curriculum::SORTABLE_MAP.each do |k, v|
        context "with sort field: #{k}" do        
          subject { get :index, :sort => k }
          it "returns the page" do
            subject.should render_template('index')
          end
        end
      end
    end
  end

  describe "GET 'edit'" do
    subject { get :edit, :id => "abc" }
    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in super_admin
      end

      context "with valid curriculum" do
        subject { get :edit, :id => curriculum.id }

        it "returns the edit" do
          subject.should render_template("edit")
        end
      end

      context "with invalid curriculum" do
        subject { get :edit, :id => "abc" }

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
      before(:each) do
        sign_in super_admin
      end

      context "with valid curriculum" do
        let(:curriculum_subject) {FactoryGirl.create(:subject)}
        let(:curriculum_grade) {FactoryGirl.create(:curriculum_grade)}
        let(:area) {FactoryGirl.create(:curriculum_area)}

        let(:params) {
          {
            :curriculum => {
              :curriculum_core_value => "New Core",
              :subject_id => curriculum_subject.id,
              :curriculum_grade_id => curriculum_grade.id,
              :curriculum_area_id => area.id,
              :standard => 3,
              :description1 => Faker::Lorem.sentence(10),
              :description2 => Faker::Lorem.paragraph(2)
            }
          }
        }

        subject { put :update, params.merge(:id => curriculum.id) }

        it "updates the curriculum information" do
          subject.should redirect_to(:action => 'index')
          cur = assigns(:curriculum)
          params[:curriculum].each do |k, v|
            next if k == :curriculum_core_value
            cur[k].should == v
          end

          cur.curriculum_core.name.should eq(params[:curriculum][:curriculum_core_value])
        end
      end

      context "with invalid curriculum" do
        context "with unavailable curriculum id" do
          subject { put :update, :id => "abc" }

          it "renders 'page_not_found'" do
            subject.response_code.should == 404
          end
        end

        context "when updating failed" do
          subject { put :update, :id => curriculum.id }

          it "returns the error" do
            Curriculum.any_instance.stub(:update_attributes).and_return(false)
            subject.should render_template('edit')
          end
        end

        context "with unexpected error" do
          subject { put :update, :id => curriculum.id }

          it "returns the error" do
            Curriculum.any_instance.stub(:update_attributes).and_raise(Exception.new("Fatal error!"))
            subject.should render_template('edit')
          end
        end
      end
    end
  end

  describe "DELETE 'destroy'", :destroy => true do
    subject { delete :destroy, :id => "abc" }
    include_examples "unauthorized"

    context "authorized" do
      before(:each) do
        sign_in super_admin
      end

      context "with valid curriculum" do        
        subject { delete :destroy, :id => curriculum.id }

        it "deletes the curriculum and redirect to index" do
          id = curriculum.id
          subject.should redirect_to(:action => 'index')
          cur = Curriculum.find_by_id(id)
          cur.should be_nil
        end
      end

      context "with invalid curriculum" do
        subject { delete :destroy, :id => "abc" }

         it "renders 'page_not_found'" do
          subject.response_code.should == 404
        end
      end

      context "destroy failed" do
        subject { delete :destroy, :id => curriculum.id }

        it "returns the error" do
          Curriculum.any_instance.stub(:destroy).and_return(false)
          subject.response_code.should == 302
          get :index
          response.body.should =~ /#{I18n.t("curriculum.delete_failed", :name => curriculum.name)}/m
        end

        context "because the curriculum is used by any goals" do
          let(:goal) {FactoryGirl.create(:goal, :curriculum => curriculum)}

          it "returns the error" do
            goal
            subject.response_code.should == 302
            get :index
            response.body.should =~ /#{I18n.t("curriculum.error_delete_in_used", :name => curriculum.name)}/m
          end
        end

        context "because of an unexpected error" do
          it "returns the error" do
            Curriculum.any_instance.stub(:destroy).and_raise(Exception.new("Fatal error!"))
            subject.response_code.should == 302
            get :index
            response.body.should =~ /#{I18n.t("curriculum.delete_failed_without_name")}/m
          end
        end
      end
    end
  end
end
