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
  belongs_to :goal
  has_many :grades, :dependent => :destroy

  # VALIDATION
  validates :accuracy, :numericality => true, :inclusion => {:in => 0..100, :message => :out_of_range_100}
  validates_presence_of :accuracy, :due_date
	validate :validate_due_date

	attr_accessor :baseline_date, :goal_date

  def due_date_string
    ::Util.date_to_string(self.due_date)
  end

  # Override property setter.
  def due_date=(date)
    date = ::Util.try_and_convert_date(date)
    self.send(:write_attribute, :due_date, date)
  end

  protected
  
  	def validate_due_date
      if (self.baseline_date > self.due_date)
        self.errors.add(:due_date, :must_eq_greater_than_baseline)
        return false
      end

      if (self.goal_date < self.due_date)
        self.errors.add(:due_date, :must_eq_less_than_goal_due_date)
        return false
      end
    end
end
