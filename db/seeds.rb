# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Create seed admin
admin = User.new
admin.assign_attributes({
  :email => "admin@teacher.com",
  :first_name => "Super",
  :last_name => "Mario",
  :password => "123456",
  :password_confirmation => "123456"
})

admin.save!

["SEACO FPI 5.1", "SEACO FPI 5.2"].each do |curriculum|
  Curriculum.create!(:name => curriculum)  
end

["Math", "French"].each do |subject|
  Subject.create!(:name => subject)  
end
