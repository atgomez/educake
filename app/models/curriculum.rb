class Curriculum < ActiveRecord::Base
  attr_accessible :name
  has_many :goals

  # VALIDATION
  validates :name, :presence => true, :uniqueness => true
end
