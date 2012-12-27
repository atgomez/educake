# == Schema Information
#
# Table name: curriculum_cores
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CurriculumCore < ActiveRecord::Base
  attr_accessible :name
  # Use inverse_of in order to save the curriculum_core when the curriculum saved.
  has_many :curriculums, :inverse_of => :curriculum_core, :dependent => :restrict

  # VALIDATION
  validates :name, :presence => true, :uniqueness => true
end
