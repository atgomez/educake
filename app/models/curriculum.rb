# == Schema Information
#
# Table name: curriculums
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Curriculum < ActiveRecord::Base
  attr_accessible :name
  has_many :goals, :dependent => :restrict

  # VALIDATION
  validates :name, :presence => true, :uniqueness => true
end
