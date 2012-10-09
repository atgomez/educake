class Status < ActiveRecord::Base
  attr_accessible :accuracy, :due_date, :goal_id
  belongs_to :goal 
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

