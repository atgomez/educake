# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Clean all Roles
Role.destroy_all

# Create Roles
Role::ROLE_NAMES.each do |role_name|
  Role.create(:name => role_name.titleize)
end

# Create a Super Admin
super_admin = User.new
super_admin.assign_attributes({
  :email => "anne.gomez@techpropulsionlabs.com",
  :first_name => "Super",
  :last_name => "Admin",
  :password => "123456",
  :password_confirmation => "123456"
})
super_admin.is_admin = true
super_admin.skip_confirmation!
super_admin.save!

CurriculumCore.destroy_all
# CurriculumCore
["Common Core"].each do |name|
  CurriculumCore.create!(:name => name)
end

Subject.destroy_all
# Create seed Subjects
["MATH", "ELA"].each do |name|
  Subject.create!(:name => name)
end

CurriculumGrade.destroy_all
# CurriculumGrade
["2"].each do |name|
  CurriculumGrade.create!(:name => name)
end

# CurriculumArea
CurriculumArea.destroy_all
["OA", "NBT", "W", "L"].each do |name|
  CurriculumArea.create!(:name => name)
end
