class Status < ActiveRecord::Base
  attr_accessible :accuracy, :due_date, :goal_id
  belongs_to :goal

  # VALIDATION
  validates_presence_of :accuracy, :due_date, :goal_id, :if => :condition_goal
  validates :accuracy, :numericality => true
  # Instance methods.
   
  def condition_goal 
    !:goal_id.nil?
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

