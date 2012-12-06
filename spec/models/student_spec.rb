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
  let(:teacher) {FactoryGirl.create(:teacher)}

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
  end

  describe ".load_data" do
    before(:all) do
      10.times do |t|
        FactoryGirl.create(:student, :teacher => teacher)
      end
    end

    include_examples "paging_exact_page_size", Student, {:page_id => 1, :page_size => 4}
  end

  describe ".search_data" do
    context "with valid query" do
      before(:all) do
        @student = FactoryGirl.create(:student, :first_name => "John", :last_name => "Carter")
      end

      it "returns the correct result" do
        result = Student.search_data("john")
        result.collect(&:id).include?(@student.id).should be_true
      end
    end

    context "with valid query and paging" do
      before(:all) do
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
      before(:all) do
        @student = FactoryGirl.create(:student, :first_name => "John", :last_name => "Carter")
      end

      it "returns an empty result" do
        result = Student.search_data("xxx")
        result.empty?.should be_true
      end
    end
  end
end
