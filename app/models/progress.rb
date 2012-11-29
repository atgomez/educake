# == Schema Information
#
# Table name: progresses
#
#  id         :integer          not null, primary key
#  goal_id    :integer          not null
#  due_date   :date             not null
#  accuracy   :float            default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Progress < ActiveRecord::Base
  attr_accessible :accuracy, :due_date
  belongs_to :goal
  has_many :statuses, :dependent => :destroy

  # VALIDATION
  validates :accuracy, :numericality => true, :inclusion => {:in => 0..100, :message => "must be from 0 to 100"}
  validates_presence_of :accuracy, :due_date
	validate :validate_due_date

	attr_accessor :baseline_date, :goal_date

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
  
  	def validate_due_date
      if (self.baseline_date > self.due_date)
        self.errors.add(:due_date, "must be equal or greater than baseline date")
        return false
      end

      if (self.goal_date < self.due_date)
        self.errors.add(:due_date, "must be equal or less than goal due date")
        return false
      end
    end
end
