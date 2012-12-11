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
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe StudentSharing do
  let(:sharing) {FactoryGirl.create(:student_sharing)}
  let(:teacher) {FactoryGirl.create(:teacher)}

  describe "#full_name" do
    it "returns the full name of shared user" do
      sharing.full_name.should == "#{sharing.first_name} #{sharing.last_name}"
    end
  end

  context "with user" do
    before(:each) do
      sharing.update_attributes(:user_id => teacher.id)
    end

    describe "#confirmed?" do
      it "returns true" do
        sharing.confirmed?.should be_true
      end
    end
  end

  context "without user" do
    describe "#confirmed?" do
      it "returns false" do
        sharing.confirmed?.should be_false
      end
    end
  end

  describe "#save_token" do
    it "saves the user id" do
      new_sharing = FactoryGirl.create(:student_sharing, :email => teacher.email)
      new_sharing.user_id.should == teacher.id
    end
  end
end
