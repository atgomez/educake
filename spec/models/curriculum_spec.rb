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
    context "with available record" do
      it "returns the correct name" do
        curriculum.name.should == 
          "#{curriculum.subject.name} #{curriculum.curriculum_grade.name}.#{curriculum.curriculum_area.name}.#{curriculum.standard}"
      end
    end

    context "with new record" do
      it "returns the name normally and not crash" do
        cur = Curriculum.new
        cur.name.should be_kind_of(String)
      end
    end
  end

  describe "#full_name" do
    context "with available record" do
      it "returns the correct full name" do
        curriculum.full_name.should == 
          "#{curriculum.curriculum_core.name}, #{curriculum.name}"
      end
    end

    context "with new record" do
      it "returns the full name normally and not crash" do
        cur = Curriculum.new
        cur.full_name.should be_kind_of(String)
      end
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

  describe ".build_curriculum", :build_curriculum => true do
    context "with an available curriculum" do
      it "builds a new curriculum with the same attributes as sample one" do
        cur = Curriculum.build_curriculum(curriculum)
        Curriculum.accessible_attributes.each do |k|
          next if k == "id"
          cur[k].should == curriculum[k]
        end
      end
    end

    context "without sample curriculum" do
      it "builds an empty curriculum object" do
        curriculum.destroy
        cur = Curriculum.build_curriculum
        Curriculum.accessible_attributes.each do |k|
          next if k == "id"
          cur[k].should be_blank
        end
      end
    end
  end

  describe ".import_data", :import_data => true do    
    context "with valid CSV file" do
      let(:csv_file) {fixture_file_upload('/files/curriculums.csv')}
      let(:fixed_curriculum) {FactoryGirl.create(:fixed_curriculum)}
      
      it "imports and update data correctly" do
        fixed_curriculum
        result = Curriculum.import_data(csv_file.path)
        result[:errors].should be_blank
      end

      context "with importing new records failure" do
        it "handles and returns the error" do
          Curriculum.any_instance.stub(:save).and_return(false)
          result = Curriculum.import_data(csv_file.path)
          result[:errors].should_not be_blank
        end
      end

      context "with updating available records failure", :current => true do
        it "handles and returns the error" do
          fixed_curriculum
          Curriculum.any_instance.stub(:update_attributes).and_return(false)
          result = Curriculum.import_data(csv_file.path)
          result[:errors].should_not be_blank
        end
      end

      context "with unexpected error" do
        it "handles and returns the error" do
          Curriculum.any_instance.stub(:save).and_raise(Exception.new("Fatal error!"))
          result = Curriculum.import_data(csv_file.path)
          result[:errors].should_not be_blank
          puts result[:errors].inspect
        end
      end
    end
  end

  describe "serialization" do
    it "returns object as Hash" do
      curriculum.to_hash.should be_kind_of(Hash)
    end
  end
end
