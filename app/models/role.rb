class Role < ActiveRecord::Base
  attr_accessible :name
  has_many :student_sharings
end
