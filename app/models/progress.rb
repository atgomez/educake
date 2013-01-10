# == Schema Information
#
# Table name: progresses
#
#  id         :integer          not null, primary key
#  goal_id    :integer          not null
#  due_date   :date             not null
#  accuracy   :float            default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Progress < ActiveRecord::Base
  attr_accessible :accuracy, :due_date
  attr_accessor :baseline_date, :goal_date

  belongs_to :goal, :touch => true
  has_many :grades

  # VALIDATION
  validates :accuracy, :numericality => true, :inclusion => {:in => 0..100, :message => :out_of_range_100}
  validates_presence_of :accuracy, :due_date
	validate :validate_due_date	

  # CALLBACK
  after_destroy :after_destroy_clear_grades_progress_id

  def due_date_string
    ::Util.date_to_string(self.due_date)
  end

  # Override property setter.
  def due_date=(date)
    date = ::Util.try_and_convert_date(date)
    self.send(:write_attribute, :due_date, date)
  end

  def status
    if (due_date > Date.today) # The due_date still be in future
      return self.goal.on_track? ? "ok" : "not ok"
    else
      (grades.order(:due_date).last) && (grades.order(:due_date).last.value >= accuracy) ? "completed" : "missed"
    end
  end

  protected
  
  	def validate_due_date
      return false if self.baseline_date.blank? || self.due_date.blank?

      if (self.baseline_date > self.due_date)
        self.errors.add(:due_date, :must_eq_greater_than_baseline)
        return false
      end

      if (self.goal_date < self.due_date)
        self.errors.add(:due_date, :must_eq_less_than_goal_due_date)
        return false
      end
    end

    def after_destroy_clear_grades_progress_id
      Grade.update_all({:progress_id => nil}, {:progress_id => self.id})
    end
end
