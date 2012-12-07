# == Schema Information
#
# Table name: students
#
#  id                 :integer          not null, primary key
#  first_name         :string(255)      not null
#  last_name          :string(255)      not null
#  birthday           :date             not null
#  teacher_id         :integer
#  gender             :boolean
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'spec_helper'

describe Student do
  let(:teacher) {
    FactoryGirl.create(:teacher)
  }
  let(:student) {FactoryGirl.create(:student, :teacher => teacher)}
  let(:txt_file) {fixture_file_upload('/files/data.txt', 'text/plain')}
  let(:png_file) {fixture_file_upload('/files/search.png', 'image/png')}
  let(:date_format) {I18n.t("date.formats.default")}
  
  describe "validate" do
    let(:dummy_student) {Student.new}

    context "invalid student" do
      [:first_name, :last_name, :birthday].each do |attr|
        it { dummy_student.should have_at_least(1).error_on(attr) }
      end

      context "with invalid photo" do
        it "has error on photo" do          
          dummy_student.photo = txt_file
          dummy_student.valid?
          dummy_student.errors[:photo].blank?.should be_false
        end
      end

      context "without photo" do
        it "does not need to validate photo type" do
          dummy_student.photo = nil
          dummy_student.valid?
          dummy_student.errors[:photo].blank?.should be_true
        end
      end
    end
  end # validations

  describe ".students_of_teacher" do    
    let(:student1) { FactoryGirl.create(:student, :teacher => teacher)  }
    let(:student2) { FactoryGirl.create(:student, :teacher => teacher)  }

    it "returns correct students" do
      # Force create sample students
      student1
      student2

      students = Student.students_of_teacher(teacher).collect(&:id)
      students.include?(student1.id).should be_true
      students.include?(student2.id).should be_true
    end
  end # Student.students_of_teacher

  describe ".load_data" do
    before(:each) do
      10.times do |t|
        FactoryGirl.create(:student, :teacher => teacher)
      end
    end

    include_examples "paging_exact_page_size", Student, {:page_id => 1, :page_size => 4}
  end # Student.load_data

  describe ".search_data" do
    context "with valid query" do
      before(:each) do
        @student = FactoryGirl.create(:student, :first_name => "John", :last_name => "Carter")
      end

      it "returns the correct result" do
        result = Student.search_data("john")
        result.collect(&:id).include?(@student.id).should be_true
      end
    end

    context "with valid query and paging" do
      before(:each) do
        10.times do |t|
          FactoryGirl.create(:student, :first_name => "John #{t}", :last_name => "Carter #{t}")
        end
      end

      it "returns result with exactly page size" do
        params = {:page_id => 1, :page_size => 4}
        result = Student.search_data("john", params)
        result.size.should equal(params[:page_size])
      end
    end

    context "with invalid query" do
      before(:each) do
        @student = FactoryGirl.create(:student, :first_name => "John", :last_name => "Carter")
      end

      it "returns an empty result" do
        result = Student.search_data("xxx")
        result.empty?.should be_true
      end
    end
  end # Student.search_data

  describe "#goals_grades" do
    before(:each) do
      2.times { FactoryGirl.create(:goal_with_grades, :student => student) }
    end

    it "returns correct data" do
      result = student.goals_grades
      result.nil?.should be_false
    end
  end

  describe "#photo_url" do
    context "with photo" do
      it "returns the photo url with no parameter" do
        student.stub_chain(:photo, :url).with(:small).and_return("file/url")
        student.photo_url.blank?.should be_false
      end
    end

    context "without photo" do
      it "returns the default photo" do
        student.photo_url.should == Student.attachment_definitions[:photo][:default_url]
      end
    end
  end

  describe "#full_name" do
    it "returns the correct full name" do
      student.full_name.should == "#{student.first_name} #{student.last_name}"
    end
  end

  describe "#birthday_string" do
    it {student.full_name.should be_a_kind_of(String)}
  end

  describe "#birthday=(value)" do
    context "with String input" , :date => true do
      before(:each) do
        @input = Date.new(1990, 10, 10).strftime(date_format)
        student.birthday = @input
      end

      it { student.birthday.should be_a_kind_of(Date) }
      it { student.birthday.strftime(date_format).should == @input}
    end

    context "with Date input" do
      before(:each) do
        @input = Date.new(1990, 10, 10)
        student.birthday = @input
      end

      it { student.birthday.should be_a_kind_of(Date) }
    end

    context "with Nil" do

    end
  end
end
