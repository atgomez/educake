# == Schema Information
#
# Table name: curriculum_areas
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe CurriculumArea do
  describe "validates presence of name" do
    let(:area) {CurriculumArea.new}
    it { area.should have_at_least(1).error_on(:name) }
  end

  describe "validates uniqueness of name" do
    let(:area) {FactoryGirl.create(:curriculum_area)}
    it "should validate uniqueness of name" do
      area1 = CurriculumArea.new(:name => area.name)
      area.should have_at_least(1).error_on(:name)
    end
  end
end
