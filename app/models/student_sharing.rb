class StudentSharing < ActiveRecord::Base
  attr_accessible :email, :name, :student_id, :user_id

  # ASSOCIATION
  belongs_to :student
  belongs_to :user
  
  # VALIDATION
  validates :name, :email, :student_id, :presence => true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
end

# == Schema Information
#
# Table name: student_sharings
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  email      :string(255)      not null
#  role_id    :integer
#  student_id :integer          not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

