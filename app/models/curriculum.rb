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
  include ::SharedMethods::Paging

  attr_accessor :curriculum_core_value

  attr_accessible :curriculum_core_id, :subject_id, :curriculum_grade_id, :curriculum_area_id,
                  :standard, :description1, :description2,
                  :curriculum_core_value # Virtual attribute

  SORTABLE_MAP = {
    "curriculum_core" => "curriculum_cores.name",
    "subject" => "subjects.name",
    "grade" => "curriculum_grades.name",
    "area" => "curriculum_areas.name",
    "standard" => "curriculums.standard",
    "description" => "curriculums.description1"
  }

  # ASSOCIATIONS

  # Use inverse_of in order to save the curriculum_core when the curriculum saved.
  belongs_to :curriculum_core, :inverse_of => :curriculums
  belongs_to :subject
  belongs_to :curriculum_grade
  belongs_to :curriculum_area
  has_many :goals, :dependent => :restrict

  # VALIDATION
  validates :curriculum_core, :subject, :curriculum_grade, :curriculum_area, 
            :standard, :description1, :description2, :presence => true  
  validates :standard, :uniqueness => { :scope => [ :curriculum_core_id, :subject_id, 
                                                    :curriculum_grade_id, :curriculum_area_id]}
  before_validation :init_curriculum_core

  #                                                    
  # CLASS METHODS
  #
  class << self
    def load_data(params = {})
      paging_info = parse_paging_options(params)
      # Paginate with Will_paginate.
      self.includes(:curriculum_core, :subject, 
        :curriculum_grade, :curriculum_area
      ).paginate({ :page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string
      })
    end

    protected

      # Parse params to PagingInfo object.
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => "curriculums.created_at DESC"
          }
        end
        paging_options(options, default_opts)
      end
  end # End class method.

  #                                                    
  # INSTANCE METHODS
  #

  # Curriculum name
  def name
    "#{self.subject.name} #{self.curriculum_grade.name}.#{self.curriculum_area.name}.#{self.standard}"
  end

  def curriculum_core_id=(value)
    @curriculum_core_value = value
    self.send(:write_attribute, :curriculum_core_id, value)
  end

  def curriculum_core_value
    @curriculum_core_value ||= self.curriculum_core_id
  end

  def curriculum_core_value=(value)
    @curriculum_core_value = value
  end

  protected

    # Init CurriculumCore if necessary
    def init_curriculum_core
      if self.curriculum_core_value != self.curriculum_core_id && !self.curriculum_core_value.blank?
        # Find by ID first
        tmp_core = nil
        if ::Util.is_a_number?(self.curriculum_core_value)
          tmp_core = CurriculumCore.find_by_id(self.curriculum_core_value)
        end

        if tmp_core.blank?
          # Find by name
          tmp_core = CurriculumCore.find_or_initialize_by_name(self.curriculum_core_value)
        end
        self.curriculum_core = tmp_core
      else
        self.curriculum_core_id = self.curriculum_core_value
      end
    end
end
