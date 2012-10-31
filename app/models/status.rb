class Status < ActiveRecord::Base
  attr_accessible :accuracy, :due_date, :goal_id, :is_ideal, :user_id, :value, :time_to_complete
  belongs_to :goal
  belongs_to :user
  # VALIDATION
  validates_presence_of :value, :due_date, :goal_id, :time_to_complete
  validates :accuracy, :numericality => true
  # Instance methods.
  # is_ideal == true <~ Progress Object
  scope :is_ideal, lambda {|ideal| where(:is_ideal => ideal)}

  before_update :update_status_state
  before_save :validate_due_date

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
      if date
        date = date.to_date
      end
    end
    self.send(:write_attribute, :due_date, date)
  end

  protected 
    def update_status_state
      self.goal.update_status_state(self)
    end

    def validate_due_date
      if (self.goal.baseline_date > self.due_date)
        self.errors.add(:due_date, "must be equal or greater than goal baseline date")
        return false
      end

      if (self.goal.due_date < self.due_date)
        self.errors.add(:due_date, "must be equal or less than goal due date")
        return false
      end
    end
end

# == Schema Information
#
# Table name: statuses
#
#  id         :integer          not null, primary key
#  goal_id    :integer          not null
#  due_date   :date
#  accuracy   :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

