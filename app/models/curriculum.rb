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

  def curriculum_core_value
    @curriculum_core_value ||= self.curriculum_core_id
  end
end
