class School < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :name, :phone, :state, :zipcode
  has_many :users
end
