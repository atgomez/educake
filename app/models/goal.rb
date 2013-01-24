# == Schema Information
#
# Table name: goals
#
#  id                :integer          not null, primary key
#  student_id        :integer          not null
#  curriculum_id     :integer          not null
#  accuracy          :float            default(0.0), not null
#  baseline          :float            default(0.0), not null
#  baseline_date     :date             not null
#  due_date          :date             not null
#  trial_days_total  :integer          not null
#  trial_days_actual :integer          not null
#  description       :text
#  is_completed      :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'csv'

class Goal < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig

  attr_accessible :accuracy, :curriculum_id, :due_date, :progresses_attributes, :curriculum_attributes,
                  :baseline_date, :baseline, :trial_days_total, :trial_days_actual, 
                  :grades_data, :is_completed, :description, :student_id

  # ASSOCIATION
  has_many :progresses, :dependent => :destroy
  has_many :grades, :dependent => :destroy
  belongs_to :student
  belongs_to :curriculum  
  
  # VALIDATION
  validates_presence_of :accuracy, :curriculum_id, :student_id,
                        :baseline, :trial_days_total, :trial_days_actual, :baseline_date, :due_date
  validates :accuracy, :numericality => true, :inclusion => {:in => 0..100, :message => :out_of_range_100}
  validates :baseline, :numericality => true, :inclusion => {:in => 0..100, :message => :out_of_range_100}
  
  validate :custom_validations

  # NESTED ATTRIBUTE
  accepts_nested_attributes_for :curriculum
  accepts_nested_attributes_for :progresses, :reject_if => lambda { |progress| 

    if progress['id'].blank?
      (progress['accuracy'].blank? || progress['due_date'].blank?)
    else
      if progress['accuracy'].blank? && progress['due_date'].blank?
        false # Not rejected => allow to be removed
      else
        (progress['accuracy'].blank? || progress['due_date'].blank?)  # Rejected
      end
    end
  }

  # PAPERCLIP ATTACHMENT

  has_attached_file :grades_data, 
                    #:storage => :s3, 
                    #:s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                    :url  => ":rails_root/public/imports/:id/:style.:extension",
                    :path => ":rails_root/public/imports/:id/:style.:extension"
  
  # SCOPE
  scope :incomplete, where('is_completed = ?', false)
  attr_accessor :last_grade #For add/update purpose

  # CALLBACK
  before_validation :update_progresses, :valid_date_attribute?, :checK_curriculum, 
                    :mark_progresses_for_removal
  after_validation :reset_curriculum
  after_save :update_all_grade  

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
      # Build the sample Curriculum
      goal.curriculum = Curriculum.build_curriculum
      return goal
    end

    # Names of methods will be exposed when serializing object to JSON, XML, etc.
    def exposed_methods
      []
    end
    
    # Names of attributes will be exposed when serializing object to JSON, XML, etc.
    def exposed_attributes
      [ :id, :student_id, :curriculum_id, :accuracy, :baseline, :trial_days_actual, :trial_days_total,
        :description, :is_completed, :baseline_date, :due_date
      ]
    end
    
    # Names of ActiveRecord associations will be exposed when serializing object to JSON, XML, etc.
    def exposed_associations
      []
    end

    protected

      # Parse params to PagingInfo object.
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => "goals.created_at DESC"
          }
        end
        paging_options(options, default_opts)
      end      
  end # End class method.

  #
  # Instance methods.
  #

  # Returns the full name of this goal, including subject, curriculum, etc.
  def name
    self.curriculum.name
  end

  def update_grade_state(grade)
    due_date = grade.due_date

    # Initilization Data
    arr_progress_date = []
    arr_progress_accuracy = []

    arr_progress_date << self.baseline_date
    arr_progress_accuracy << self.baseline

    progresses = self.progresses.order('due_date ASC')
    assign_progress = false

    progresses.each do |progress|
      arr_progress_date << progress.due_date
      arr_progress_accuracy << progress.accuracy
      if !assign_progress && progress.due_date >= grade.due_date
        grade.progress = progress
      end
    end

    arr_progress_date << self.due_date
    arr_progress_accuracy << self.accuracy

    #
    # Find the progress contains this grade
    #
    current_progress_index = arr_progress_date.length - 1 # Default is goal date
    tmp_index = 0
    arr_progress_date.each do |progress_date|
      if (progress_date >= due_date)
        current_progress_index = tmp_index
        break
      end

      tmp_index = tmp_index + 1
    end

    current_progress = arr_progress_accuracy[current_progress_index]
    current_due_date = arr_progress_date[current_progress_index]

    previous_progress = arr_progress_accuracy[current_progress_index - 1]
    previous_due_date = arr_progress_date[current_progress_index - 1]

    #
    # Set the ideal value
    #
    distance_day_of_grade = (due_date - previous_due_date).to_i
    distance_day_of_progress = (current_due_date - previous_due_date).to_i
    needed_value_for_ideal_goal = current_progress - previous_progress

    ideal_increment_value = needed_value_for_ideal_goal*distance_day_of_grade/distance_day_of_progress
    grade.ideal_value = previous_progress + ideal_increment_value

    #
    # Find the value
    #
    
    # Get the list of [trial_days_total] previous grades
    previous_grades = self.grades.find(:all, :conditions => ['grades.due_date < ?', grade.due_date], :order => 'due_date DESC', :limit => (self.trial_days_total - 1))
    
    # Sort by accuracy
    previous_grades = previous_grades.sort_by { |hsh| hsh[:accuracy] }

    if previous_grades.count >= (self.trial_days_total - 1) #If enough grades for calculating
      lowest_value_count = self.trial_days_total - self.trial_days_actual
      sum_value = 0
      # Calculate the sume of rest value
      (lowest_value_count...(self.trial_days_total - 1)).each {|index| sum_value = sum_value + previous_grades[index][:accuracy]}
      # Add current grade value to total
      sum_value = sum_value + grade.accuracy.to_f
      grade.value = sum_value/self.trial_days_actual
      grade.is_unused = false

    else # If not enough grade, set accuracy equal to value
      grade.value = grade.accuracy
      grade.is_unused = true
    end
    return grade
  end

  # Get date in string.
  def due_date_string
    ::Util.date_to_string(self.due_date)
  end

  def baseline_date_string
    ::Util.date_to_string(self.baseline_date)
  end

  # Override property setter.
  def due_date=(date)
    date = ::Util.try_and_convert_date(date)
    self.send(:write_attribute, :due_date, date)
  end

  def baseline_date=(date)
    date = ::Util.try_and_convert_date(date)
    self.send(:write_attribute, :baseline_date, date)
  end

  def last_grade
    self.grades.order(:due_date).last
  end

  # Check if a grade exist in now
  def on_grade_now?
    !self.grades.where(:due_date => Time.now).blank?
  end

  # Check if number of grades over trial date total
  def on_over_trial_days?
    result = false
    if self.last_grade and self.grades.length >= self.trial_days_total
      result = true
    end
    return result
  end

  # Check if the goal is on-track or not.
  def on_track?
    result = false

    # TODO: should limit the minimum date?
    # min_date = Time.zone.now.to_date - self.trial_days_total.days
    
    recent_grades = self.grades.order(
      "due_date DESC"
    ).limit(self.trial_days_actual)

    actual_value = 0
    ideal_value = 0
    total_grade = 0

    recent_grades.each do |grade|
      total_grade += 1
      actual_value += grade.accuracy
      ideal_value += grade.ideal_value
    end

    if total_grade > 0
      result = (actual_value/total_grade > ideal_value/total_grade)
    end
    return result
  end

  # Calculate ideal % for a date.
  # This value can be show on the ideal line on the goal chart.
  # The formula is simple: use the square triangle tang(eagle) formula:
  #
  #                 C.      
  #         E.       |
  # A.______D._______|B
  #  |               | 
  #  |               |
  # O|______F._______|G
  #
  # Given:
  #   - OA is the less nearest progress accuracy (or goal's baseline)
  #   - GC is the great nearest progress accuracy (or goal's accuracy)
  #   - BC = (GC - OA)
  #   - (*) EF is a random value between OA and GC, this is the unknown value.
  #
  # Our goal is calculating the value of EF.
  #
  # How to do?
  # We have ABC is a square triagle.
  #   tang(A) = ED/AD = BC/AB
  #   => ED = AD*BC/AB (gotcha!)
  #   => EF = OA + ED
  #
  def graph_ideal_value_for_date(date)
    # Firstly, try to use goal's baseline and target
    if self.baseline_date >= date
      return self.baseline
    elsif self.due_date <= date
      return self.accuracy
    end

    # Secondly, try to check if there is any progress exact on the given day
    exact_progress = nil
    if self.association(:progresses).loaded?
      # Search in memory
      exact_progress = self.progresses.detect{|p| p.due_date == date}
    else
      # Search in DB
      exact_progress = self.progresses.where(:due_date => date).first
    end

    unless exact_progress.blank?
      return exact_progress.accuracy      
    end

    # Thirdly, we're unlucky, let calculate it!

    # The nearest progress that less than the given date
    begin_progress = nil
    # The nearest progress that bigger than the given date
    end_progress = nil

    if self.association(:progresses).loaded?
      # Search in memory
      begin_progress = self.progresses.sort_by(&:due_date).reverse.detect{|p| p.due_date <= date}
      end_progress = self.progresses.sort_by(&:due_date).detect{|p| p.due_date >= date}
    else
      # Search in DB
      begin_progress = self.progresses.where("due_date <= ?", date).order("due_date DESC").first
      end_progress = self.progresses.where("due_date >= ?", date).order("due_date ASC").first
    end

    # Get the necessary data.
    begin_date = nil
    begin_value = nil
    end_date = 0
    end_value = 0

    if begin_progress
      begin_date = begin_progress.due_date
      begin_value = begin_progress.accuracy
    else
      # Use baseline
      begin_date = self.baseline_date
      begin_value = self.baseline
    end

    if end_progress
      end_date = end_progress.due_date
      end_value = end_progress.accuracy
    else
      # Use the deadline
      end_date = self.due_date
      end_value = self.accuracy
    end

    # Caculate the value
    # Please see the triangle above to understand the meaning of variables.
    ad = (date - begin_date).to_i
    ab = (end_date - begin_date).to_i
    bc = (end_value - begin_value).abs

    if ab == 0
      return 0
    else
      return (begin_value + (ad*bc/ab))
    end
  end

  def build_progresses
    count_progress = self.progresses.length
    # Create remaining progresses
    (3 - count_progress).times { self.progresses.build } if count_progress < 3
  end

  def build_grade(params, is_updatable = false)

    #Find progress
    progress = self.progresses.order('due_date ASC').where('due_date >= ?', params[:due_date]).first
    grade = nil
    if is_updatable
      grade = self.grades.find_or_initialize_by_due_date(params[:due_date])
      grade.goal = self
      grade.accuracy = params[:accuracy]
      grade.time_to_complete = params[:time_to_complete]
    else
      grade = self.grades.new params
    end
    
    if progress
      grade.progress = progress
    end
    return grade
  end
  
  def parse_csv(path)
    grades = []
    CSV.foreach(path) do |row|
      grades << {
          :due_date => row[0],
          :accuracy => row[1].split("%").first,
          :time_to_complete => row[2]
        }
    end

    return grades
  end 
  
  def goal_grade
    grade = self.last_grade
    if (grade)
      vs_baseline = grade.value - self.baseline
      vs_baseline/(self.accuracy - self.baseline)*100
    else
      0
    end
  end

  # EXPORTING
  def export_xml(package, context, tmpdir, sheet_index)

    # Create Header Info
    package.workbook.add_worksheet(:name => "#{self.name[0...25]} #{sheet_index}") do |sheet|
      # Student Header
      yield(sheet) if block_given?

      # Styling
      left_text_style = sheet.styles.add_style ChartProcess::LEFT_TEXT_STYLE
      bold = sheet.styles.add_style ChartProcess::BOLD_STYLE
      wrap_text = sheet.styles.add_style ChartProcess::WRAP_TEXT

      # Goal Header
      sheet.add_row ["Report Date:", Date.today], :style => [left_text_style , nil]
      sheet.add_row [""], :style => left_text_style
      sheet.add_row ["", "Status", "Due Date", "On Track"], :style => [left_text_style, bold, bold, bold]
      sheet.add_row [self.name, "#{accuracy}%", 
                      due_date, 
                      on_track? ? "ok" : "not ok"], 
                    :style => [left_text_style, nil]
      sheet.add_row [""], :style => left_text_style
      idx = 0
      self.progresses.order(:due_date).each do |progress|
        sheet.add_row [idx > 0 ? "" : "Progress Reports", "#{progress.accuracy}%", progress.due_date, progress.status], :style => [left_text_style, nil]
      idx = idx + 1
      end
      sheet.add_row [""], :style => left_text_style
      sheet.add_row ["Trial Days", "#{trial_days_actual}/#{trial_days_total}"], :style => [left_text_style, nil]
      sheet.add_row ["Goal Description", self.curriculum.try(:description1), ""], :style => [left_text_style, wrap_text, nil]
      sheet.add_row ["", self.curriculum.try(:description2), ""], :style => [left_text_style, wrap_text, nil]
      sheet.add_row ["", self.description, ""], :style => [left_text_style, wrap_text, nil]
      sheet.column_widths nil, 30, nil
      (1..3).each {sheet.add_row [""], :style => left_text_style}

      sheet.add_row ["", "Date","Score"], :style => [left_text_style, bold, bold]
      self.grades.order('due_date DESC').each do |grade|
        sheet.add_row ["", grade.due_date, "#{grade.accuracy}%"], :style => [left_text_style, nil]
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
    # For add grade  
    data = []
    self.grades.find_each{|grade| 
      data << [grade.due_date, (grade.accuracy*100).round / 100.0]
    }
    data = data.sort_by { |hsh| hsh[0] }
    series << {
                 :name => self.name,
                 :data => data,
                 :color => color 
                }
    series.to_json
  end

  def update_all_grade
    self.transaction do
      self.grades.find_each do |grade|
        self.update_grade_state(grade)
        grade.save
      end
    end      
  end

  def subject
    @subject ||= self.curriculum.subject
  end  

  protected

    def update_progresses
      self.progresses.each do |progress| 
        progress.baseline_date = self.baseline_date
        progress.goal_date = self.due_date
      end
    end

    # Run all custom validations
    def custom_validations
      self.validate_baseline && validate_baseline_date && self.validate_trial_days && self.validates_goal_name 
    end

    def validate_baseline
      if self.baseline.to_f >= self.accuracy.to_f
        self.errors.add(:baseline, :must_lower_than_goal)
      end
      return self.errors.blank?
    end

    def validate_baseline_date
      if self.baseline_date && self.due_date && self.baseline_date >= self.due_date
        self.errors.add(:baseline_date, :must_lower_than_due_date)
      elsif self.baseline_date && self.grades.exists?(["due_date < ?", self.baseline_date])
        # In case of changing goal baseline to some date greater than grade's date.
        self.errors.add(:baseline_date, :must_before_grade_due_date)
      end

      return self.errors.blank?
    end

    def validate_trial_days
      if self.trial_days_actual.to_i >= self.trial_days_total.to_i
        self.errors.add(:trial_days_actual, :must_lower_than_ideal)
      end
      return self.errors.blank?
    end
    
    def validates_goal_name
      scoped_goal = Goal.where('student_id = ? AND id <> ?', self.student_id, self.id || 0)
      existed = scoped_goal.exists?(:curriculum_id => self.curriculum_id, 
        :due_date => self.due_date)
      if existed 
        self.errors.add(:due_date, :taken)
        self.errors.add(:curriculum_id, :taken)
      end 
      return !existed
    end 

    def valid_date_attribute?
      ::Util.check_date_validation(self, @attributes, :baseline_date, true)
      ::Util.check_date_validation(self, @attributes, :due_date, true)
    end

    def checK_curriculum
      unless self.curriculum.blank?
        cur = self.curriculum
        attrs = {
          :curriculum_core_id => cur.curriculum_core_id, 
          :subject_id => cur.subject_id, 
          :curriculum_grade_id => cur.curriculum_grade_id, 
          :curriculum_area_id => cur.curriculum_area_id,
          :standard => cur.standard
        }
        self.curriculum = Curriculum.where(attrs).first

        if self.curriculum.blank?
          self.curriculum = Curriculum.new(attrs)
        end
      end
    end

    def reset_curriculum
      unless self.errors.blank?
        self.curriculum = Curriculum.build_curriculum(self.curriculum)
      end
    end

    # Mark progresses as beign removed
    def mark_progresses_for_removal
      self.progresses.each do |p|
        if p.due_date.blank? && p.accuracy.to_i <= 0
          p.mark_for_destruction
        end
      end
    end
end
