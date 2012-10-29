class Goal < ActiveRecord::Base
  include ::SharedMethods::Paging
  attr_accessible :accuracy, :curriculum_id, :due_date, :subject_id, :statuses_attributes
  has_many :statuses, :dependent => :destroy
  belongs_to :student 
  belongs_to :subject 
  belongs_to :curriculum
  
  validates :accuracy, :numericality => true
  validates_presence_of :accuracy, :due_date, :curriculum_id, :subject_id
  accepts_nested_attributes_for :statuses, :reject_if => lambda { |a| 
    a['accuracy'].blank? || a['due_date'].blank?
  }
  
  def name 
    [self.subject.name, self.curriculum.name].join(" ")
  end 
  # Class methods
  class << self
    def build_goal(attrs = {})
      goal = self.new(attrs)
      goal.build_statuses
      return goal
    end
  end

  # Instance methods.

  # Get due_date in string.
  def due_date_string
    ::Util.date_to_string(self.due_date)
  end

  # Override property setter.
  def due_date=(date)
    if date.is_a?(String)
      date = ::Util.format_date(date)
      if date
        date = date.to_date
      end
    end
    self.send(:write_attribute, :due_date, date)
  end

  def build_statuses
    3.times { self.statuses.build }
  end
  class << self
    def load_data(params = {}, complete = nil)
      paging_info = parse_paging_options(params)
      # Paginate with Will_paginate.
      conds = { :page => paging_info.page_id,
                :per_page => paging_info.page_size,
                :order => paging_info.sort_string
              }
      unless complete.nil?
          conds = conds.merge(:conditions => ["is_completed = ?", complete])
      end 
      self.paginate(conds)
    end
    
    protected

      # Parse params to PagingInfo object.
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => "created_at DESC"
          }
        end
        paging_options(options, default_opts)
      end
  end
end

# == Schema Information
#
# Table name: goals
#
#  id            :integer          not null, primary key
#  student_id    :integer          not null
#  subject_id    :integer          not null
#  curriculum_id :integer          not null
#  due_date      :date
#  accuracy      :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  is_completed  :boolean
#

