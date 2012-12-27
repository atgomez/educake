# == Schema Information
#
# Table name: curriculum_cores
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe CurriculumCore do
  describe "validates presence of name" do
    let(:record) {CurriculumCore.new}
    it { 
      record.valid?
      record.should have_at_least(1).error_on(:name) 
    }
  end

  describe "validates uniqueness of name" do
    let(:record) {FactoryGirl.create(:curriculum_core)}
    it "should validate uniqueness of name" do
      record1 = CurriculumCore.new(:name => record.name)
      record1.valid?
      record1.should have_at_least(1).error_on(:name)
    end
  end
end
