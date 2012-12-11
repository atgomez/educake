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

  describe "#goals_grades", :goal_grades => true do
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
    it {student.birthday_string.should be_a_kind_of(String)}
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
      it { 
        student.birthday = nil
        student.birthday.should be_nil 
      }
    end
  end

  describe "#gender_string" do
    context "Unknown" do
      it {student.gender_string.should == I18n.t('common.gender.unknown')}
    end

    context "Male" do
      it {
        student.gender = true
        student.gender_string.should == I18n.t('common.gender.male')
      }
    end

    context "Female" do
      it {
        student.gender = false
        student.gender_string.should == I18n.t('common.gender.female')
      }
    end
  end

  context "with student sharing", :with_sharing => true do
    let(:shared_teacher) {FactoryGirl.create(:teacher)}
    let(:shared_parent) {FactoryGirl.create(:parent)}
    let(:sharing_teacher) {
      FactoryGirl.create(
        :student_sharing, 
        :student => student, 
        :user => shared_teacher,
        :role => shared_teacher.role
      )
    }

    let(:sharing_parent) {
      FactoryGirl.create(
        :student_sharing, 
        :student => student, 
        :user => shared_parent,
        :role => shared_parent.role
      )
    }

    let(:expected_result) { [student.teacher_id, shared_teacher.id, shared_parent.id] }

    before(:each) do
      sharing_teacher
      sharing_parent
    end

    describe "#sponsors", :sponsors => true do    
      context "without role name input" do
        it "returns the correct sponsors of the student" do
          result = student.sponsors.collect(&:id)
          (result - expected_result).should be_empty          
        end
      end

      context "with role name input as underscore symbol" do
        it "returns the correct sponsors of the student" do
          result = student.sponsors(:teacher).collect(&:id)
          result.length.should == 2
          result.include?(student.teacher_id).should be_true
          result.include?(shared_teacher.id).should be_true
        end
      end

      context "with correct role full name like 'Parent' or 'Teacher'" do
        it "returns the correct sponsors of the student" do
          result = student.sponsors("Teacher").collect(&:id)
          result.length.should == 2
          result.include?(student.teacher_id).should be_true
          result.include?(shared_teacher.id).should be_true
        end
      end

      context "with invalid role name" do
        it "returns only student teachers" do
          result = student.sponsors(:abc).collect(&:id)
          result.length.should == 1
          result.include?(student.teacher_id).should be_true
        end
      end
    end # sponsors

    describe "#shared_users_with_role", :shared_users_with_role => true do    
      context "with valid role name" do
        it "returns the shared users" do
          result = student.shared_users_with_role(:teacher).collect(&:id)
          result.length.should == 1
          result.include?(shared_teacher.id)
        end
      end

      context "with invalid role name" do
        it "returns nothing" do
          result = student.shared_users_with_role(:abc).collect(&:id)
          result.should be_empty
        end
      end
    end # shared_users_with_role

    describe "#sponsoring_teachers" do
      it "returns all teachers of this student" do
        result = student.sponsoring_teachers.collect(&:id)
        result.length.should == 2
        result.include?(student.teacher_id).should be_true
        result.include?(shared_teacher.id).should be_true
      end
    end
  end # with_sharing

  describe "#check_on_track?", :check_on_track => true do
    context "with goals" do
      before(:each) do
        2.times { FactoryGirl.create(:goal_with_grades, :student => student) }
      end

      context "with ALL on-track goals" do
        it "returns 1 (on-track)" do
          Goal.any_instance.stub(:on_track?).and_return(true)
          student.check_on_track?.should == 1
        end
      end

      context "with ONE not on-track goal" do
        it "returns 2 (not on-track)" do
          Goal.any_instance.stub(:on_track?).and_return(false)
          student.check_on_track?.should == 2
        end
      end
    end

    context "with no goals" do
      it "return 0 (not available)" do
        student.check_on_track?.should == 0
      end
    end
  end

  describe "#export_xml", :export_xml => true do    
    let(:package) { Axlsx::Package.new }
    let(:context) { ExportController.new }
    
    let(:tmp_dir) { 
      path = File.expand_path "#{Rails.root.join('tmp')}/#{Time.now.to_i}#{rand(1000)}/"
      FileUtils.mkdir_p(path)
      path
    }

    let(:tmp_file) {
      temp = Tempfile.new("student-#{Time.now.to_i}.xlsx", tmp_dir)
      temp.path
    }

    context "with goals" do
      before(:each) do
        2.times { FactoryGirl.create(:goal_with_grades, :student => student) }
      end

      it "returns the export file" do
        result = student.export_xml(package, context, tmp_dir, tmp_file)
        result.should be_true
      end
    end

    context "with no goals" do
      it "can run and return the export file" do
        result = student.export_xml(package, context, tmp_dir, tmp_file)
        result.should be_true
      end
    end
  end

  describe "#series_json", :series_json => true do
    before(:each) do
      2.times { FactoryGirl.create(:goal_with_grades, :student => student) }
    end

    it "returns JSON data" do
      result = student.series_json
      result.should be_a_kind_of(String)
      JSON.parse(result).should be_a_kind_of(Array)
    end
  end
end
