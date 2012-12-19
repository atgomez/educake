# == Schema Information
#
# Table name: grades
#
#  id               :integer          not null, primary key
#  goal_id          :integer          not null
#  user_id          :integer
#  progress_id      :integer
#  due_date         :date             not null
#  accuracy         :float            default(0.0), not null
#  value            :float            default(0.0)
#  ideal_value      :float            default(0.0)
#  time_to_complete :time
#  is_unused        :boolean          default(FALSE)
#  note             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Grade < ActiveRecord::Base
  include ::SharedMethods::Paging  

  attr_accessible :accuracy, :due_date, :goal_id, :user_id,
                  :value, :time_to_complete, :is_unused, :note
  
  # ASSOCIATIONS
  belongs_to :user
  belongs_to :goal, :touch => true
  belongs_to :progress

  # VALIDATION
  validates :accuracy, :numericality => true, 
            :inclusion => {:in => 0..100, :message => "must be from 0 to 100"}
  validates :goal_id, :uniqueness => { :scope => :due_date,
            :message => "should happen once per day" }
  validates_presence_of :accuracy, :due_date, :goal_id

  # SCOPE
  scope :computable, where('is_unused = ?', false)

  # CALLBACK
  before_update :update_grade_state
  before_save :validate_due_date
  
  # CLASS METHODS
  class << self
    def show_errors(message, errors)
      html = ""
      msgs = errors.slice(0, 4)
      html += "<div>"+message+"</div>"
      msgs.map do |msg|
        html += "<div>"+msg+"</div>"
      end
      return html.html_safe
    end 
    def load_data(params = {})
      paging_info = parse_paging_options(params)
      # Paginate with Will_paginate.
      conds = { :page => paging_info.page_id,
                :per_page => 15,#paging_info.page_size,
                :order => paging_info.sort_string
              }
      self.paginate(conds)
    end
    
    protected

      # Parse params to PagingInfo object.
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => "due_date ASC"
          }
        end
        paging_options(options, default_opts)
      end
  end # End class method.

  def condition_goal 
    !goal_id.nil?
  end
   
  def due_date_string
    ::Util.date_to_string(self.due_date)
  end

  # Override property setter.
  def due_date=(date)
    if date.is_a?(String)
      date = ::Util.format_date(date)      
    end

    if date
      date = date.to_date
    end
    self.send(:write_attribute, :due_date, date)
  end
  
  
  protected
  
    def update_grade_state
      self.goal.update_grade_state(self)
    end

    def validate_due_date
      if (self.goal.baseline_date > self.due_date)
        self.errors.add(:due_date, "must be equal or greater than goal baseline date")
        return false
      end

      if (self.goal.due_date < self.due_date)
        self.errors.add(:due_date, "must be less than or equal to goal due date")
        return false
      end
      if (self.due_date > Time.zone.now.to_date)
        self.errors.add(:due_date, "must be less than or equal to today")
        return false
      end
    end
end
