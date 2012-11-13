# == Schema Information
#
# Table name: statuses
#
#  id               :integer          not null, primary key
#  goal_id          :integer          not null
#  due_date         :date
#  accuracy         :float
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  is_ideal         :boolean          default(TRUE)
#  user_id          :integer
#  value            :float            default(0.0)
#  ideal_value      :float            default(0.0)
#  time_to_complete :time
#  progress_id      :integer
#  is_unused        :boolean          default(FALSE)
#  note             :text
#

class Status < ActiveRecord::Base
  attr_accessible :accuracy, :due_date, :goal_id, :is_ideal, :user_id, :value, :time_to_complete, :is_unused, :note
  belongs_to :user
  belongs_to :goal
  belongs_to :progress

  # VALIDATION
  validates :accuracy, :numericality => true, :inclusion => {:in => 0..100, :message => "must be from 0 to 100"}
  validates :goal_id, :uniqueness => { :scope => :due_date,
    :message => "should happen once per day" }
  validates_presence_of :accuracy, :due_date, :goal_id
  # Instance methods.
  # is_ideal == true <~ Progress Object
  scope :is_ideal, lambda {|ideal| where(:is_ideal => ideal)}
  scope :computable, where('is_unused = ?', false)

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
