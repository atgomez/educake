# == Schema Information
#
# Table name: subscribers
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  is_accept  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Subscriber do
  describe "Load Data" do
    before(:each) do
      10.times do |t|
        FactoryGirl.create(:subscriber)
      end
    end

    include_examples "paging_exact_page_size", Subscriber, {:page_id => 1, :page_size => 4}
  end 

end
