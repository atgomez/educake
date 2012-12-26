# == Schema Information
#
# Table name: curriculums
#
#  id                  :integer          not null, primary key
#  curriculum_core_id  :integer          not null
#  subject_id          :integer          not null
#  curriculum_grade_id :integer          not null
#  curriculum_area_id  :integer          not null
#  standard            :integer          not null
#  description1        :string(255)      not null
#  description2        :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'spec_helper'

describe Curriculum do
  let(:curriculum) {FactoryGirl.create(:curriculum)}

  describe ".load_data" do
    before(:each) do
      10.times do |t|
        FactoryGirl.create(:curriculum)
      end
    end

    include_examples "paging_exact_page_size", Curriculum, {:page_id => 1, :page_size => 4}
  end # .load_data

  describe "#name" do
    it "returns the correct name" do
      curriculum.name.should == 
        "#{curriculum.subject.name} #{curriculum.curriculum_grade.name}.#{curriculum.curriculum_area.name}.#{curriculum.standard}"
    end
  end

  describe "#curriculum_core_value" do
    context "without initialization" do
      it "returns the value equal with curriculum_core_id" do
        curriculum.curriculum_core_value.should eq(curriculum.curriculum_core_id)
      end
    end

    context "with initialization" do
      it "returns the initialized value of curriculum_core_value" do
        curriculum.curriculum_core_value = "New Common Core"
        curriculum.curriculum_core_value.should_not eq(curriculum.curriculum_core_id)
      end
    end
  end

  describe "Automatically create new CurriculumCore" do
    let(:curriculum_core) {FactoryGirl.create(:curriculum_core)}

    context "with a brand new curriculum core name" do
      it "creates a new CurriculumCore object" do
        new_core_name = "New Core Name"
        curriculum.curriculum_core_value = new_core_name
        curriculum.save!
        curriculum.curriculum_core.name.should eq(new_core_name)
      end
    end

    context "with a brand new curriculum core name (as a number)" do
      it "creates a new CurriculumCore object" do
        new_core_name = "123456"
        curriculum.curriculum_core_value = new_core_name
        curriculum.save!
        curriculum.curriculum_core.name.should eq(new_core_name)
      end
    end

    context "with an available curriculum core name" do      
      it "should only change the curriculum_core_id and not create a new CurriculumCore object" do
        curriculum.curriculum_core_value = curriculum_core.name
        curriculum.save!
        curriculum.reload
        curriculum.curriculum_core.name.should eq(curriculum_core.name)
      end
    end

    context "with an available curriculum core id" do
      it "should only change the curriculum_core_id and not create a new CurriculumCore object" do
        curriculum.curriculum_core_value = curriculum_core.id
        curriculum.save!
        curriculum.reload
        curriculum.curriculum_core.name.should eq(curriculum_core.name)
      end
    end 

    context "with changing of curriculum_core_id" do
      it "normally save the changed value" do
        curriculum.curriculum_core_id = curriculum_core.id
        curriculum.save!
        curriculum.reload
        curriculum.curriculum_core.name.should eq(curriculum_core.name)
      end
    end
  end
end
