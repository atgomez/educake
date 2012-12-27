# == Schema Information
#
# Table name: student_sharings
#
#  id            :integer          not null, primary key
#  first_name    :string(255)      not null
#  last_name     :string(255)      not null
#  email         :string(255)      not null
#  student_id    :integer          not null
#  user_id       :integer
#  role_id       :integer          not null
#  confirm_token :string(255)
#  is_blocked    :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe StudentSharing do  
  let(:teacher) {FactoryGirl.create(:teacher)}
  let(:student) {FactoryGirl.create(:student, :teacher => teacher)}
  let(:parent) {FactoryGirl.create(:parent, :school => teacher.school)}
  let(:sharing) {FactoryGirl.create(:student_sharing, :student => student, :email => parent.email)}

  describe "#full_name" do
    it "returns the full name of shared user", :full_name => true do
      sharing.full_name.should == "#{sharing.first_name} #{sharing.last_name}"
    end
  end

  context "with user" do
    describe "#confirmed?", :confirmed => true do
      it "returns true" do
        sharing.confirmed?.should be_true
      end
    end
  end

  context "without user" do
    let(:new_sharing) {FactoryGirl.create(:student_sharing)}
    describe "#confirmed?" do
      it "returns false" do
        new_sharing.confirmed?.should be_false
      end
    end
  end

  describe "#save_token" do
    let(:new_teacher) {FactoryGirl.create(:teacher, :school => teacher.school)}
    let(:student) {FactoryGirl.create(:student, :teacher => new_teacher)}

    it "saves the user id" do
      new_sharing = FactoryGirl.create(:student_sharing, :student => student, :email => teacher.email)
      new_sharing.user_id.should == teacher.id
    end
  end
end
