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
