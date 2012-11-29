# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ActiveRecord::Base
  ROLE_NAMES = %w[admin teacher parent]
  attr_accessible :name
  has_many :student_sharings, :dependent => :restrict
  has_many :users, :dependent => :restrict

  scope :with_name, lambda { |*names|
    names.map!{|n| n.to_s.titleize}
    where(:name => names)
  }
end
