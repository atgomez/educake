# == Schema Information
#
# Table name: curriculum_areas
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CurriculumArea < ActiveRecord::Base
  attr_accessible :name
  has_many :curriculums, :dependent => :restrict

  # VALIDATION
  validates :name, :presence => true, :uniqueness => true
end
