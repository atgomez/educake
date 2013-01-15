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
  validates_presence_of :accuracy, :goal_id
  validates :accuracy, :numericality => true, 
            :inclusion => {:in => 0..100, :message => :out_of_range_100}
  validates :goal_id, :uniqueness => { :scope => :due_date, :message => :only_once_per_day }
  

  # SCOPE
  scope :computable, where('is_unused = ?', false)

  # CALLBACK
  before_validation :valid_date_attribute?
  before_save :validate_due_date
  
  # CLASS METHODS
  class << self
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

  # Comment this 'cuz unused method
  # def condition_goal 
  #   !goal_id.nil?
  # end
   
  def due_date_string
    ::Util.date_to_string(self.due_date)
  end

  # Override property setter.
  def due_date=(date)
    date = ::Util.try_and_convert_date(date)
    self.send(:write_attribute, :due_date, date)
  end
  
  
  protected

    def valid_date_attribute?
      ::Util.check_date_validation(self, @attributes, :due_date, true)
    end

    def validate_due_date
      
      if (self.goal.baseline_date > self.due_date)
        self.errors.add(:due_date, :must_eq_greater_than_goal_baseline)
        return false
      end

      if (self.goal.due_date < self.due_date)
        self.errors.add(:due_date, :must_eq_less_than_goal_due_date)
        return false
      end
      if (self.due_date > Time.zone.now.to_date)
        self.errors.add(:due_date, :must_eq_less_than_goal_today)
        return false
      end
    end
end
