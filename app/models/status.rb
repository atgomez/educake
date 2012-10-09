class Status < ActiveRecord::Base
  attr_accessible :accuracy, :due_date, :goal_id
  belongs_to :goal 
end
