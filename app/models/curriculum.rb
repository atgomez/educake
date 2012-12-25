# == Schema Information
#
# Table name: curriculums
#
#  id                  :integer          not null, primary key
#  curriculum_core_id  :integer          not null
#  subject_id          :integer          not null
#  curriculum_grade_id :integer          not null
#  curriculum_area_id  :integer          not null
#  standard            :integer          not null
#  description1        :string(255)      not null
#  description2        :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Curriculum < ActiveRecord::Base
  attr_accessible :curriculum_core_id, :subject_id, :curriculum_grade_id, :curriculum_area_id,
                  :standard, :description1, :description2

  # ASSOCIATIONS
  belongs_to :curriculum_core
  belongs_to :subject
  belongs_to :curriculum_grade
  belongs_to :curriculum_area
  has_many :goals, :dependent => :restrict

  # VALIDATION
  validates :curriculum_core_id, :subject_id, :curriculum_grade_id, :curriculum_area_id, 
            :standard, :description1, :description2, :presence => true
  validates :standard, :uniqueness => { :scope => [ :curriculum_core_id, :subject_id, 
                                                    :curriculum_grade_id, :curriculum_area_id]}
end
