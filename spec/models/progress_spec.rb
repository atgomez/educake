# == Schema Information
#
# Table name: progresses
#
#  id         :integer          not null, primary key
#  goal_id    :integer          not null
#  due_date   :date             not null
#  accuracy   :float            default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Progress do
  let(:progress) {FactoryGirl.create(:progress)}

  describe "#due_date_string" do
    it "return a string" do
      progress.due_date_string.should be_kind_of(String)
    end
  end

  describe "#due_date=(value)" do
    context "with invalid value" do
      it "sets the nil value for the attribute" do
        progress.due_date = "abc"
        progress.due_date.should be_nil
      end
    end

    context "with the nil value" do
      it "sets the nil value for the attribute" do
        progress.due_date = "abc"
        progress.due_date.should be_nil
      end
    end

    context "with a valid value" do
      context "with the date value" do
        it "sets the correct value" do
          input = Time.now.to_date
          progress.due_date = input
          progress.due_date.should == input
        end
      end

      context "with a string value" do
        it "sets the correct value" do
          input = Time.now.to_date        
          progress.due_date = input.strftime(I18n.t("date.formats.default"))
          progress.due_date.should == input
        end
      end
    end
  end

  describe "#after_destroy_clear_grades_progress_id" do
    it "calls after_destroy_clear_grades_progress_id after destroyed" do
      progress.should_receive(:after_destroy_clear_grades_progress_id)
      progress.destroy
    end
  end
end
