class Goal < ActiveRecord::Base
  attr_accessible :accuracy, :curriculum_id, :due_date, :subject_id
  has_many :statuses, :dependent => :destroy
  belongs_to :subject 
  belongs_to :curriculum
  
  validates_presence_of :accuracy, :due_date, :curriculum_id, :subject_id
end

# == Schema Information
#
# Table name: goals
#
#  id            :integer          not null, primary key
#  subject_id    :integer          not null
#  curriculum_id :integer          not null
#  due_date      :date
#  accuracy      :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

