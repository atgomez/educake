class Goal < ActiveRecord::Base
  attr_accessible :accuracy, :curriculum_id, :due_date, :subject_id, :statuses_attributes
  has_many :statuses, :dependent => :destroy
  belongs_to :student 
  belongs_to :subject 
  belongs_to :curriculum
  
  validates_presence_of :accuracy, :due_date, :curriculum_id, :subject_id
  accepts_nested_attributes_for :statuses, :reject_if => lambda { |a| 
    a['accuracy'].blank? || a['due_date'].blank?
  }
  
  # Class methods
  class << self
    def build_goal(attrs = {})
      goal = self.new(attrs)
      goal.build_statuses
      return goal
    end
  end

  # Instance methods.

  # Get due_date in string.
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

  def build_statuses
    3.times { self.statuses.build }
  end
end

# == Schema Information
#
# Table name: goals
#
#  id            :integer          not null, primary key
#  student_id    :integer          not null
#  subject_id    :integer          not null
#  curriculum_id :integer          not null
#  due_date      :date
#  accuracy      :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

