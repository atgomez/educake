# == Schema Information
#
# Table name: schools
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  address1   :string(255)      not null
#  address2   :string(255)
#  city       :string(255)
#  state      :string(255)      not null
#  zipcode    :string(255)
#  phone      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe School do
  let(:school) {FactoryGirl.create(:school)}

  describe ".load_data" do
    before(:each) do
      10.times do |t|
        FactoryGirl.create(:school)
      end
    end

    include_examples "paging_exact_page_size", School, {:page_id => 1, :page_size => 4}
  end # School.load_data

  describe "#statistic" do
    let(:teacher) {FactoryGirl.create(:teacher, :parent => school.admin, :school => school)}
    let(:parent) {FactoryGirl.create(:parent, :parent => school.admin, :school => school)}
    let(:student) {FactoryGirl.create(:student, :teacher => teacher)}

    context "without student sharing" do
      it "returns the correct number of teacher/parent and students" do
        teacher
        parent
        student

        result = school.statistic
        result[:teachers_count].should == 2
        result[:students_count].should == 1
      end
    end

    context "with student sharing" do
      let(:sharing_teacher) {
        FactoryGirl.create(
          :student_sharing, 
          :student => student, 
          :user => teacher,
          :role => teacher.role
        )
      }

      it "returns the correct number of teacher/parent and students" do
        sharing_teacher
        parent
        result = school.statistic
        result[:teachers_count].should == 2
        result[:students_count].should == 1
      end
    end
  end
end
