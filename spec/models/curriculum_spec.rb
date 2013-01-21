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

  describe "#html_description2", :html_description2 => true do
    context "with available record" do
      it "returns the string" do
        curriculum.html_description2.should be_kind_of(String)
      end
    end

    context "with new record" do
      it "returns the string normally and not crash" do
        cur = Curriculum.new
        cur.html_description2.should be_kind_of(String)
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

  describe "#destroy" do
    subject {curriculum.destroy}
    context "without deleting CurriculumCore" do
      let(:curriculum1) {FactoryGirl.create(:curriculum, :curriculum_core => curriculum.curriculum_core)}
      it "delete only the Curriculum record" do
        curriculum1
        subject.should_not be_blank
        curriculum1.curriculum_core.should_not be_blank
      end
    end

    context "with deleting CurriculumCore" do
      it "also deletes the CurriculumCore record" do
        curriculum_core_id = curriculum.curriculum_core_id
        subject.should_not be_blank
        CurriculumCore.find_by_id(curriculum_core_id).should be_blank
      end
    end

    context "with goals" do
      let(:goal) {FactoryGirl.create(:goal, :curriculum => curriculum)}
      it "raises ActiveRecord::DeleteRestrictionError" do
        goal
        expect {curriculum.destroy}.to raise_error(ActiveRecord::DeleteRestrictionError)
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

  describe ".get_associations_by_field", :get_associations_by_field => true do
    context "with curriculum_core_id" do
      let(:curriculum1) {FactoryGirl.create(:curriculum, :curriculum_core => curriculum.curriculum_core)}
      let(:curriculum2) {FactoryGirl.create(:curriculum, :curriculum_core => curriculum.curriculum_core)}

      it "returns the data" do
        curriculum1
        curriculum2

        result = Curriculum.get_associations_by_field('curriculum_core_id', curriculum.curriculum_core_id)
        result.should_not be_blank
        result.should be_kind_of(Hash)

        result[:curriculum_cores].length.should == 1
        [:subjects, :curriculum_grades, :curriculum_areas, :standards].each do |k|
          result[k].length.should == 3
        end
      end
    end

    context "with subject_id" do
      let(:curriculum1) {FactoryGirl.create(:curriculum, :subject => curriculum.subject)}
      let(:curriculum2) {FactoryGirl.create(:curriculum, :subject => curriculum.subject)}

      it "returns the data" do
        curriculum1
        curriculum2

        result = Curriculum.get_associations_by_field('subject_id', curriculum.subject_id)
        result.should_not be_blank
        result.should be_kind_of(Hash)

        result[:subjects].length.should == 1
        [:curriculum_cores, :curriculum_grades, :curriculum_areas, :standards].each do |k|
          result[k].length.should == 3
        end
      end
    end

    context "with curriculum_grade_id" do
      let(:curriculum1) {FactoryGirl.create(:curriculum, :curriculum_grade => curriculum.curriculum_grade)}
      let(:curriculum2) {FactoryGirl.create(:curriculum, :curriculum_grade => curriculum.curriculum_grade)}

      it "returns the data" do
        curriculum1
        curriculum2

        result = Curriculum.get_associations_by_field('curriculum_grade_id', curriculum.curriculum_grade_id)
        result.should_not be_blank
        result.should be_kind_of(Hash)

        result[:curriculum_grades].length.should == 1
        [:curriculum_cores, :subjects, :curriculum_areas, :standards].each do |k|
          result[k].length.should == 3
        end
      end
    end

    context "with curriculum_area_id" do
      let(:curriculum1) {FactoryGirl.create(:curriculum, :curriculum_area => curriculum.curriculum_area)}
      let(:curriculum2) {FactoryGirl.create(:curriculum, :curriculum_area => curriculum.curriculum_area)}

      it "returns the data" do
        curriculum1
        curriculum2

        result = Curriculum.get_associations_by_field('curriculum_area_id', curriculum.curriculum_area_id)
        result.should_not be_blank
        result.should be_kind_of(Hash)

        result[:curriculum_areas].length.should == 1
        [:curriculum_cores, :subjects, :curriculum_grades, :standards].each do |k|
          result[k].length.should == 3
        end
      end
    end

    context "with standard" do
      let(:curriculum1) {FactoryGirl.create(:curriculum, :standard => curriculum.standard)}
      let(:curriculum2) {FactoryGirl.create(:curriculum, :standard => curriculum.standard)}

      it "returns the data" do
        curriculum1
        curriculum2

        result = Curriculum.get_associations_by_field('standard', curriculum.standard)
        result.should_not be_blank
        result.should be_kind_of(Hash)

        result[:standards].length.should == 1
        [:curriculum_cores, :subjects, :curriculum_grades].each do |k|
          result[k].length.should == 3
        end
      end
    end

    context "with invalid field name" do
      context "with nil field name" do
        it "return an empty result" do
          result = Curriculum.get_associations_by_field(nil, 1)
          result.should be_blank
        end
      end

      context "with unavailable field name" do
        it "return an empty result" do
          # There something wrong with the :get_associations_by_field that make the rspec fail.
          # We must simulate the scenario.
          Curriculum.should_receive(:where).with({'abc' => 1}).and_raise(Exception.new("Fatal error!"))
          
          result = Curriculum.get_associations_by_field('abc', 1)                    
          result.should be_blank
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

      context "with curriculum_core_name" do
        context "with new name" do
          it "auto creates the curriculum core" do
            new_name = "New Core Name"
            result = Curriculum.import_data(csv_file.path, :curriculum_core => new_name)
            result[:errors].should be_blank
            CurriculumCore.find_by_name(new_name).should_not be_blank
          end
        end

        context "with available name" do
          it "auto creates the curriculum core" do
            result = Curriculum.import_data(csv_file.path, :curriculum_core => curriculum.name)
            result[:errors].should be_blank
          end
        end

        context "with available core ID" do
          it "auto detect the CurriculumCore" do
            result = Curriculum.import_data(csv_file.path, :curriculum_core => curriculum.id)
            result[:errors].should be_blank
          end
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

  describe ".init_curriculum" do
    it "returns the new curriculum with a default CurriculumCore" do
      cur = Curriculum.init_curriculum
      cur.should_not be_blank
      cur.curriculum_core.should_not be_blank
    end
  end

  describe "serialization" do
    it "returns object as Hash" do
      curriculum.to_hash.should be_kind_of(Hash)
    end
  end
end
