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

require 'csv'
require 'buffered_hash'

class Curriculum < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig  

  attr_accessor :curriculum_core_value

  attr_accessible :curriculum_core_id, :subject_id, :curriculum_grade_id, :curriculum_area_id,
                  :standard, :description1, :description2,
                  :curriculum_core_value # Virtual attribute

  DEFAULT_CSV_SEPARATOR = ","
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
  validates :description1, :length => { :maximum => 255, :too_long => :name_too_long }
  validates :standard, :uniqueness => { :scope => [ :curriculum_core_id, :subject_id, 
                                                    :curriculum_grade_id, :curriculum_area_id]}
  validates :curriculum_core_value, :presence => true
  # CALLBACK                                      
  before_validation :init_curriculum_core
  after_destroy :destroy_curriculum_core

  #                                                    
  # CLASS METHODS
  #
  class << self
    # Names of methods will be exposed when serializing object to JSON, XML, etc.
    def exposed_methods
      [:name, :full_name, :html_description2]
    end
    
    # Names of attributes will be exposed when serializing object to JSON, XML, etc.
    def exposed_attributes
      [ :id, :curriculum_core_id, :subject_id, :curriculum_grade_id, :curriculum_area_id,
        :standard, :description1, :description2]
    end
    
    # Names of ActiveRecord associations will be exposed when serializing object to JSON, XML, etc.
    def exposed_associations
      []
    end

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

    # Init curriculum with a curriculum core.
    def init_curriculum
      Curriculum.new(:curriculum_core_id => CurriculumCore.first.try(:id))
    end

    def import_data(data_source, options = {})
      # Size of each cache
      cache_size = 10

      # CurriculumCore
      curriculum_core_id = nil
      unless options[:curriculum_core].blank?
        # Find by ID first
        curriculum_core = CurriculumCore.find_by_id(options[:curriculum_core])
        if curriculum_core.blank?
          # Then find or init a new record with the name
          curriculum_core = CurriculumCore.find_or_initialize_by_name(options[:curriculum_core].to_s)
        end

        # Save the record
        if curriculum_core.new_record?
          curriculum_core.save
        end

        curriculum_core_id = curriculum_core.id
      end

      if curriculum_core_id.blank?
        # Get the default Common Core if no core name was supplied.
        curriculum_core_id = CurriculumCore.find_by_name(I18n.t("curriculum.common_core")).try(:id)
      end

      # Cache the Subject
      tmp_data = {}
      Subject.limit(cache_size).each do |r|
        tmp_data[r.name] = r.id
      end
      subjects = BufferedHash.new(cache_size, tmp_data) do |name|
        # Find and init the record if necessary
        record = Subject.find_or_initialize_by_name(name)
        if record.new_record?
          record.save!
        end
        record.id
      end

      # Cache the CurriculumGrade
      tmp_data = {}
      CurriculumGrade.limit(cache_size).each do |r|
        tmp_data[r.name] = r.id
      end
      curriculum_grades = BufferedHash.new(cache_size, tmp_data) do |name|
        # Find and init the record if necessary
        record = CurriculumGrade.find_or_initialize_by_name(name)
        if record.new_record?
          record.save!
        end
        record.id
      end

      # Cache the CurrculumArea
      tmp_data = {}
      CurriculumArea.limit(cache_size).each do |r|
        tmp_data[r.name] = r.id
      end
      curriculum_areas = BufferedHash.new(cache_size, tmp_data) do |name|
        # Find and init the record if necessary
        record = CurriculumArea.find_or_initialize_by_name(name)
        if record.new_record?
          record.save!
        end
        record.id
      end

      # Begin importing...
      errors = {}
      imported_num = 0
      line_num = 0

      Curriculum.transaction do
        options = {:skip_blanks => true, :col_sep => DEFAULT_CSV_SEPARATOR}
        CSV.foreach(data_source, options) do |row|
          if line_num == 0 # Skip header
            line_num += 1
            next
          end

          # Get the current line number
          # See http://stackoverflow.com/questions/12407035/ruby-csv-get-current-line-row-number
          # line_num = $.
          line_num += 1
          row.compact!
          # Skip this row
          next if row.blank?

          begin
            finder_attrs = {
              :curriculum_core_id => curriculum_core_id,
              :subject_id => subjects[row[0].strip],
              :curriculum_grade_id => curriculum_grades[row[1].strip],
              :curriculum_area_id => curriculum_areas[row[2].strip],
              :standard => row[3].strip              
            }

            extra_attrs = {
              :description1 => row[4].strip,
              :description2 => row[5].strip
            }

            curriculum = Curriculum.where(finder_attrs).first
            if curriculum
              if curriculum.update_attributes(extra_attrs)
                imported_num += 1
                puts "[Curriculum] Updated: #{curriculum.id}"
              else
                # Get only one error message is enough.
                errors[line_num] = curriculum.errors.full_messages.first
              end              
            else
              # Create a new curriculum
              curriculum = Curriculum.new(finder_attrs.merge(extra_attrs))
              if curriculum.save
                imported_num += 1
                puts "[Curriculum] Imported: #{curriculum.id}"
              else
                # Get only one error message is enough.
                errors[line_num] = curriculum.errors.full_messages.first
              end
            end            
          rescue Exception => exc
            ::Util.log_error(exc, "Curriculum.import_data#foreach")
            errors[line_num] = I18n.t("curriculum.import_line_failed")
          end
        end
      end

      result = {
        :imported_num => imported_num
      }
      unless errors.blank?
        result[:errors] = errors
      end
      return result
    end

    # Build a sample curriculum
    def build_curriculum(sample_curriculum = nil)
      sample_curriculum ||= Curriculum.first
      attrs = {}
      unless sample_curriculum.blank?
        # Get all accessible attributes except :id
        attrs = sample_curriculum.attributes.select{ |k,v| 
          Curriculum.accessible_attributes.include?(k) && k != "id"
        }
      end
      return Curriculum.new(attrs)
    end

    # Get associations curriculum_cores, subjects, curriculum_grades, 
    # curriculum_areas and standards by a weight field
    #
    # === Parameters
    #
    #     * field_name (String): name of the base column
    #     * field_value (String): value of the base column
    #
    # === Returns
    #
    # {
    #   :curriculum_cores=>[["CCore1", 2]], 
    #   :subjects=>[["Subject 1", 3], ["Subject 2", 4]], 
    #   :curriculum_grades=>[["Grade1", 2], ["Grade2", 3], 
    #   :curriculum_areas=>[["Area1", 5], ["Area2", 6]], 
    #   :standards=>[1, 2, 3]
    # }
    #
    def get_associations_by_field(field_name, field_value)
      data = Curriculum.where(field_name => field_value).includes(
        :curriculum_core, :subject, 
        :curriculum_grade, :curriculum_area
      )

      result = {}
      data.each do |item|
        result[:curriculum_cores] ||= []
        result[:curriculum_cores] << [item.curriculum_core.name, item.curriculum_core.id]

        result[:subjects] ||= []
        result[:subjects] << [item.subject.name, item.subject.id]

        result[:curriculum_grades] ||= []
        result[:curriculum_grades] << [item.curriculum_grade.name, item.curriculum_grade.id]

        result[:curriculum_areas] ||= []
        result[:curriculum_areas] << [item.curriculum_area.name, item.curriculum_area.id]

        result[:standards] ||= []
        result[:standards] << [item.standard, item.standard]
      end

      result.keys.each do |k|
        result[k].uniq!
        result[k] = result[k].sort_by{|i| i[0]}
      end

      # Get the first curriculum
      result[:curriculum] = data.first

      return result
    rescue Exception => exc
      ::Util.log_error(exc, "Curriculum.get_associations_by_field")
      return {}
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
    "#{self.subject.try(:name)} #{self.curriculum_grade.try(:name)}.#{self.curriculum_area.try(:name)}.#{self.standard}"
  end

  # Curriculum name with CurriculumCore
  def full_name
    "#{self.curriculum_core.try(:name)}, #{self.name}"
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

  # Return the description2 in HTML format
  def html_description2
    ::Util.simple_format(self.description2)
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

    def destroy_curriculum_core
      unless self.curriculum_core.curriculums.any?
        # Delete the curriculum_core
        self.curriculum_core.destroy
      end
    rescue Exception
    end
end
