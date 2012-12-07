# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Role do
  describe "attributes" do
    it { should have_attribute(:name) }
  end

  describe 'associations' do
    it { should have_many(:student_sharings).dependent(:restrict)}
    it { should have_many(:users).dependent(:restrict)}
  end
end
