class Invitation < ActiveRecord::Base
  attr_accessible :email, :name, :role_id, :student_id

  # ASSOCIATION
  belongs_to :student
  
  # VALIDATION
  validates :name, :email, :student_id, :presence => true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
end

# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  email      :string(255)      not null
#  role_id    :integer
#  student_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

