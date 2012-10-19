# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Create Roles
Role::ROLE_NAMES.each do |role_name|
  Role.create(:name => role_name.titleize)
end

# Create a Super Admin
super_admin = User.new
super_admin.assign_attributes({
  :email => "super.admin@teacher.com",
  :first_name => "Super",
  :last_name => "Admin",
  :password => "123456",
  :password_confirmation => "123456"
})
super_admin.is_admin = true
super_admin.skip_confirmation!
super_admin.save!

# Create seed Admin (Principal)
admin = User.new
admin.assign_attributes({
  :email => "admin@teacher.com",
  :first_name => "Super",
  :last_name => "Mario",
  :password => "123456",
  :password_confirmation => "123456",
  :school_name => "Public School"
})

admin.role = Role.find_by_name('Admin')
admin.skip_confirmation!
admin.save!

# Create seed Curriculums
["SEACO FPI 5.1", "SEACO FPI 5.2"].each do |curriculum|
  Curriculum.create!(:name => curriculum)  
end

# Create seed Subjects
["Math", "French"].each do |subject|
  Subject.create!(:name => subject)  
end
