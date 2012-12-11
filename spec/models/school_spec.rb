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
  describe ".load_data" do
    before(:each) do
      10.times do |t|
        FactoryGirl.create(:school)
      end
    end

    include_examples "paging_exact_page_size", School, {:page_id => 1, :page_size => 4}
  end # Student.load_data
end
