class Student < ActiveRecord::Base
  attr_accessible :birthday, :first_name, :gender, :last_name, :teacher_id
  belongs_to :teacher, :classname => "User"
end
