class Role < ActiveRecord::Base
  ROLE_NAMES = %w[admin teacher parent]
  attr_accessible :name
  has_many :student_sharings
  has_many :users, :dependent => :restrict
end

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

