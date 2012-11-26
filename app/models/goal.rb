# == Schema Information
#
# Table name: goals
#
#  id                  :integer          not null, primary key
#  student_id          :integer          not null
#  subject_id          :integer          not null
#  curriculum_id       :integer          not null
#  due_date            :date
#  accuracy            :float            default(0.0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  is_completed        :boolean          default(FALSE)
#  baseline            :float            default(0.0)
#  baseline_date       :date             default(Tue, 13 Nov 2012), not null
#  trial_days_total    :integer          default(0)
#  trial_days_actual   :integer          default(0)
#  is_archived         :boolean          default(FALSE)
#  grades_file_name    :string(255)
#  grades_content_type :string(255)
#  grades_file_size    :integer
#  grades_updated_at   :datetime
#  description         :text
#

require 'csv'

class Goal < ActiveRecord::Base
  include ::SharedMethods::Paging

  attr_accessible :accuracy, :curriculum_id, :due_date, :subject_id, :progresses_attributes, 
  :baseline_date, :baseline, :trial_days_total, :trial_days_actual,:is_archived, :grades, :is_completed, :description

  # ASSOCIATION
  has_many :progresses, :dependent => :destroy
  has_many :statuses, :dependent => :destroy
  belongs_to :student 
  belongs_to :subject 
  belongs_to :curriculum
  
  # VALIDATION
  validates :accuracy, :numericality => true, :inclusion => {:in => 0..100, :message => "must be from 0 to 100"}
  validates :baseline, :numericality => true, :inclusion => {:in => 0..100, :message => "must be from 0 to 100"}
  validates_presence_of :accuracy, :due_date, :curriculum_id, :subject_id, :baseline_date, :baseline, :trial_days_total, :trial_days_actual

  accepts_nested_attributes_for :progresses, :reject_if => lambda { |progress| 
    progress['accuracy'].blank? || progress['due_date'].blank?
  }

  has_attached_file :grades, 
                    #:storage => :s3, 
                    #:s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                    :url  => ":rails_root/public/imports/:id/:style.:extension",
                    :path => ":rails_root/public/imports/:id/:style.:extension"
  
  validates_attachment_content_type :grades, :content_type => ['text/csv','text/comma-separated-values','text/csv','application/csv','application/excel','application/vnd.ms-excel','application/vnd.msexcel','text/anytext','text/plain'], :message => 'file must be of filetype .csv', :if => Proc.new{|r| !r.grades.blank?}
  
  # SCOPE
  scope :is_archived, lambda {|is_archived| where(:is_archived => is_archived)} 
  scope :incomplete, where('is_completed = ?', false)
  scope :available, where('is_completed = ? AND is_archived = ?', false, false)
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

    # Initilization Data
    arr_progress_date = []
    arr_progress_accuracy = []

    arr_progress_date << self.baseline_date
    arr_progress_accuracy << self.baseline

    progresses = self.progresses.order('due_date ASC')
    progresses.each do |progress|
      arr_progress_date << progress.due_date
      arr_progress_accuracy << progress.accuracy
    end

    arr_progress_date << self.due_date
    arr_progress_accuracy << self.accuracy

    #
    # Find the progress contains this status
    #
    current_progress_index = arr_progress_date.length - 1 # Default is goal date
    tmp_index = 0
    arr_progress_date.each do |progress_date|
      if (progress_date >= due_date)
        current_progress_index = tmp_index
      end

      tmp_index = tmp_index + 1
    end

    current_progress = arr_progress_accuracy[current_progress_index]
    current_due_date = arr_progress_date[current_progress_index]

    previous_progress = arr_progress_accuracy[current_progress_index - 1]
    previous_due_date = arr_progress_date[current_progress_index - 1]

    #
    # Find the ideal value
    #
    distance_day_of_status = (status.due_date - previous_due_date).to_i
    distance_day_of_progress = (current_due_date - previous_due_date).to_i
    needed_value_for_ideal_goal = current_progress - previous_progress

    ideal_increment_value = needed_value_for_ideal_goal*distance_day_of_status/distance_day_of_progress
    status.ideal_value = previous_progress + ideal_increment_value

    #
    # Find the value
    #
    
    # Get the list of [trial_days_total] previous statuses
    previous_statuses = self.statuses.find(:all, :conditions => ['statuses.due_date < ?', status.due_date], :order => 'due_date DESC', :limit => (self.trial_days_total - 1))
    
    # Sort by accuracy
    previous_statuses = previous_statuses.sort_by { |hsh| hsh[:accuracy] }

    if previous_statuses.count >= (self.trial_days_total - 1) #If enough statuses for calculating
      lowest_value_count = self.trial_days_total - self.trial_days_actual
      sum_value = 0
      (lowest_value_count...9).each {|index| sum_value = sum_value + previous_statuses[index][:value]}

      # Add current status value to total
      sum_value = sum_value + status.accuracy
      status.value = sum_value/self.trial_days_actual
      status.is_unused = false

    else # If not enough status, set accuracy equal to value
      status.value = status.accuracy
      status.is_unused = true
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
    self.statuses.order(:due_date).last
  end

  # Check if a grade exist in now
  def on_grade_now?
    !self.statuses.where(:due_date => Time.now).blank?
  end

  # Check if number of grades over trial date total
  def on_over_trial_days?
    result = false
    if self.last_status and self.statuses.length >= self.trial_days_total
      result = true
    end
    return result
  end

  # Check if the goal is on-track or not.
  def on_track?
    result = false

    today_status = self.statuses.where(:due_date => Time.now).first
    status_value = 0
    ideal_value = 0
    if today_status
      status_value = today_status.value
      ideal_value = today_status.ideal_value
    end

    # If actual value >= ideal value => 'on-track', else 'not on-track'
    if status_value != 0 && ideal_value != 0
      result = (status_value >= ideal_value)
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

  def build_status(params, is_updatable = false)
    #Find progress
    progress = self.progresses.find(:first, :conditions => ['due_date >= ?', params[:due_date]], :order => 'due_date ASC')
    status = nil
    if is_updatable
      status = self.statuses.find_or_initialize_by_due_date(params[:due_date])
      status.goal = self
      status.accuracy = params[:accuracy]
      status.time_to_complete = params[:time_to_complete]
    else
      status = self.statuses.new params
    end
    
    if progress
      status.progress = progress
    end
    return status
  end
  
  def parse_csv(path)
    statuses = []
    CSV.foreach(path) do |row|
      statuses << {
          :due_date => row[0],
          :accuracy => row[1].split("%").first,
          :time_to_complete => row[2]
        }
    end

    return statuses
  end 
  
  def goal_status
    status = self.last_status
    if (status)
      vs_baseline = status.value - self.baseline
      vs_baseline/(self.accuracy - self.baseline)*100
    else
      0
    end
  end

  # EXPORTING
  def export_xml(package, context, tmpdir, sheet_index)

    # Create Header Info
    package.workbook.add_worksheet(:name => "#{self.name} #{sheet_index}") do |sheet|
      # Student Header
      yield(sheet) if block_given?

      # Styling
      left_text_style = sheet.styles.add_style ChartProcess::LEFT_TEXT_STYLE
      bold = sheet.styles.add_style ChartProcess::BOLD_STYLE

      # Goal Header
      sheet.add_row ["Report Date:", Date.today], :style => [left_text_style , nil]
      sheet.add_row [""], :style => left_text_style
      sheet.add_row ["", "Status", "Due Date", "On Track"], :style => [left_text_style, bold, bold, bold]
      sheet.add_row [self.name, "#{(goal_status*100).round / 100.0}%", 
                      due_date, 
                      on_track? ? "ok" : "not ok"], 
                    :style => [left_text_style, nil]
      sheet.add_row [""], :style => left_text_style
      idx = 0
      self.progresses.each do |progress|
        sheet.add_row [idx > 0 ? "" : "Progress Reports", "%", progress.due_date, ""], :style => [left_text_style, nil]
      idx = idx + 1
      end
      sheet.add_row [""], :style => left_text_style
      sheet.add_row ["Trial Days", "#{trial_days_actual}/#{trial_days_total}"], :style => [left_text_style, nil]
      sheet.add_row ["Goal Description", description], :style => [left_text_style, nil]
      (1..3).each {sheet.add_row [""], :style => left_text_style}

      sheet.add_row ["", "Date","Score"], :style => [left_text_style, bold, bold]
      self.statuses.order(:due_date).each do |status|
        sheet.add_row ["", status.due_date, "#{status.accuracy}%"], :style => [left_text_style, nil]
      end

      image_path = ChartProcess.renderPNG(context, tmpdir, self.series_json)

      sheet.add_image(:image_src => image_path, :noSelect => true, :noMove => true) do |image|
        image.width=1000
        image.height=500
        image.start_at 6, 2
      end
    end

  end

  # Collect data for charting

  def series_json(params={})
    # Create data for charts
    color = params[:color] ||= 'AA4643'
    color = '#' + color
    series = []
    data = []

    data << [self.baseline_date, (self.baseline.round*100).round  / 100.0]
    # For ideal data
    self.progresses.each{|progress| 
      data << [progress.due_date, (progress.accuracy*100).round / 100.0]
    }
    data << [self.due_date, (self.accuracy*100).round  / 100.0]
    #Sort data by due date
    data = data.sort_by { |hsh| hsh[0] }
    
    series << {
                 :type => 'line',
                 :name => "Ideal chart",
                 :data => data
                }
    if color && color == '#4572A7'
      series[0][:color] = "#AA4643"
    end
    # For add status  
    data = []
    self.statuses.each{|status| 
      data << [status.due_date, (status.accuracy*100).round / 100.0]
    }
    data = data.sort_by { |hsh| hsh[0] }
    series << {
                 :name => self.name,
                 :data => data,
                 :color => color 
                }
    series.to_json
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
