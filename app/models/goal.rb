# == Schema Information
#
# Table name: goals
#
#  id                :integer          not null, primary key
#  student_id        :integer          not null
#  subject_id        :integer          not null
#  curriculum_id     :integer          not null
#  due_date          :date
#  accuracy          :float            default(0.0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_completed      :boolean
#  baseline          :float            default(0.0)
#  baseline_date     :date             not null
#  trial_days_total  :integer          default(0)
#  trial_days_actual :integer          default(0)
#  is_archived       :boolean          default(FALSE)
#

class Goal < ActiveRecord::Base
  include ::SharedMethods::Paging
  attr_accessible :accuracy, :curriculum_id, :due_date, :subject_id, :progresses_attributes, :baseline_date, :baseline, :trial_days_total, :trial_days_actual,:is_archived
  has_many :progresses, :dependent => :destroy
  has_many :statuses, :through => :progresses
  belongs_to :student 
  belongs_to :subject 
  belongs_to :curriculum
  
  validates :accuracy, :numericality => true, :inclusion => {:in => 0..100, :message => "must be from 0 to 100"}
  validates :baseline, :numericality => true, :inclusion => {:in => 0..100, :message => "must be from 0 to 100"}
  validates_presence_of :accuracy, :due_date, :curriculum_id, :subject_id, :baseline_date, :baseline, :trial_days_total, :trial_days_actual

  accepts_nested_attributes_for :progresses, :reject_if => lambda { |progress| 
    progress['accuracy'].blank? || progress['due_date'].blank?
  }

  scope :is_archived, lambda {|is_archived| where(:is_archived => is_archived)} 
  attr_accessor :last_status #For add/update purpose

  # CALLBACK
  before_validation :update_progresses
  before_save :custom_validations
  after_save :update_all_status  
  
  # CLASS METHODS
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
    
    def build_goal(attrs = {})
      goal = self.new(attrs)
      goal.build_progresses
      return goal
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
  end # End class method.

  def name 
    [self.subject.name, self.curriculum.name].join(" ")
  end

  # Instance methods.
  def update_status_state(status)
    due_date = status.due_date
    return status if (!due_date || due_date < self.baseline_date || due_date > self.due_date)

    #
    # Find the progress contains this status
    #
    current_progress = status.progress
    # Firstly, treat the baseline info as the first progress value
    previous_progress = self.baseline
    previous_due_date = self.baseline_date

    # Get all progress and sort them
    progresses = self.progresses.order('due_date ASC')
    progresses.each do |progress|
      if (progress.due_date >= due_date)
        break
      end

      # Keep previous progress value for getting ideal value
      previous_progress = progress.accuracy
      previous_due_date = progress.due_date
    end

    #
    # Find the ideal value
    #
    distance_day_of_status = (status.due_date - previous_due_date).to_i
    distance_day_of_progress = (current_progress.due_date - previous_due_date).to_i
    needed_value_for_ideal_goal = current_progress.accuracy - previous_progress

    ideal_increment_value = needed_value_for_ideal_goal*distance_day_of_status/distance_day_of_progress
    status.ideal_value = previous_progress + ideal_increment_value

    #
    # Find the value
    #
    
    # Get the list of [trial_days_total] previous statuses
    previous_statuses = self.statuses.find(:all, :conditions => ['is_ideal = ? AND statuses.due_date < ?', false, status.due_date], :order => 'due_date DESC', :limit => (self.trial_days_total - 1))
    
    # Sort by accuracy
    previous_statuses = previous_statuses.sort_by { |hsh| hsh[:accuracy] }

    if previous_statuses.count == (self.trial_days_total - 1) #If enough statuses for calculating
      lowest_value_count = self.trial_days_total - self.trial_days_actual
      sum_value = 0
      (lowest_value_count...9).each {|index| sum_value = sum_value + previous_statuses[index][:value]}

      # Add current status value to total
      sum_value = sum_value + status.accuracy
      status.value = sum_value/self.trial_days_actual

    else # If not enough status, set accuracy equal to value
      status.value = status.accuracy
    end

    return status
  end

  # Get date in string.
  def due_date_string
    ::Util.date_to_string(self.due_date)
  end

  def baseline_date_string
    ::Util.date_to_string(self.baseline_date)
  end

  def last_status
    @last_status ||= self.statuses.order(:due_date).last
  end

  # Check if the goal is on-track or not.
  def on_track?
    result = false
    if self.last_status
      # If actual value >= ideal value => 'on-track', else 'not on-track'
      result = (self.last_status.value >= self.last_status.ideal_value)
    end
    return result
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

  def baseline_date=(date)
    if date.is_a?(String)
      date = ::Util.format_date(date)
      if date
        date = date.to_date
      end
    end
    self.send(:write_attribute, :baseline_date, date)
  end

  def build_progresses
    count_progress = self.progresses.length
    # Create remaining progresses
    (3-count_progress).times { self.progresses.build } if count_progress < 3
  end

  def build_status(params)
    #Find progress
    progress = self.progresses.find(:first, :conditions => ['due_date >= ?', params[:due_date]], :order => 'due_date ASC')
    if progress
      progress.statuses.new params
    else
      return false
    end
  end

  def goal_status
    status = last_status
    if (status)
      vs_baseline = status.value - self.baseline
      vs_baseline/(self.accuracy - self.baseline)*100
    else
      0
    end
  end

  protected

    def update_progresses
      self.progresses.each do |progress| 
        progress.baseline_date = self.baseline_date
        progress.goal_date = self.due_date
      end
    end

    def update_all_status
      self.transaction do
        self.statuses.each do |status|
          self.update_status_state(status)
          status.save
        end
      end
    end

    # Run all custom validations
    def custom_validations
      self.validate_baseline
      self.validate_trial_days
      self.validate_baseline_date
    end

    def validate_baseline
      if self.baseline.to_f >= self.accuracy.to_f
        self.errors.add(:baseline, "cannot be greater than or equal to goal percent")
      end
      return self.errors.blank?
    end

    def validate_baseline_date
      if self.baseline_date && self.due_date && self.baseline_date >= self.due_date
        self.errors.add(:baseline_date, "cannot be greater than or equal to due date")
      end
      return self.errors.blank?
    end

    def validate_trial_days
      if self.trial_days_actual.to_i >= self.trial_days_total.to_i
        self.errors.add(:trial_days_actual, "cannot be greater than or equal to the ideal trial days")
      end
      return self.errors.blank?
    end
end
