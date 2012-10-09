class Student < ActiveRecord::Base
  attr_accessible :birthday, :first_name, :gender, :last_name, :teacher_id
  belongs_to :teacher, :class_name => "User"

  # ASSOCIATION
  has_many :invitations, :dependent => :destroy

  # VALIDATION
  validates_presence_of :first_name, :last_name
end

# == Schema Information
#
# Table name: students
#
#  id         :integer          not null, primary key
#  first_name :string(255)      not null
#  last_name  :string(255)      not null
#  birthday   :date
#  teacher_id :integer
#  gender     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

