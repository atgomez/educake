class Goal < ActiveRecord::Base
  attr_accessible :accuracy, :curriculum_id, :due_date, :subject_id
  has_many :statuses
  belongs_to :subject 
  belongs_to :curriculum
  
  validates_presence_of :accuracy, :due_date, :curriculum_id, :subject_id
end
