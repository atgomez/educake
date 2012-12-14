# This file should contain dummy records creation needed to demonstrate the app or to test.
# The data can then be loaded with the rake db:sample_data.

# Create sample school
school = School.create!({
  :name => "Demo School",
  :city => Faker::Address.city,
  :state => Faker::Address.state,
  :address1 => Faker::Address.street_address,
  :phone => Faker::PhoneNumber.phone_number,
  :zipcode => Faker::Address.zip.slice(0, 5)
})

# Create the admin
password = "123456"

admin = User.new
admin.assign_attributes({
  :email => "admin@teacher.com",
  :first_name => "Super",
  :last_name => "Mario",
  :password => password,
  :password_confirmation => password,
  :school_id => school.id
})

admin.role = Role.find_by_name('Admin')
admin.skip_confirmation!
admin.save!
puts "Created seed Admin (Principal): #{admin.email} / #{password}"

# Create sample teacher
teacher_role = Role.find_by_name('Teacher')
teacher = User.new({
  :email => 'demo@teacher.com',
  :first_name => "Demo",
  :last_name => "Teacher",
  :password => password,
  :password_confirmation => password,
  :school_id => school.id
})
teacher.role = teacher_role
teacher.parent = admin
teacher.skip_confirmation!
teacher.save!
puts "[Sampler] Created demo teacher #{teacher.email} / #{password}"

10.times do 
  begin
    teacher = User.new({
      :email => Faker::Internet.email,
      :first_name => Faker::Name.first_name,
      :last_name => Faker::Name.last_name,
      :password => "123456",
      :password_confirmation => "123456",
      :school_id => school.id
    })
    teacher.role = teacher_role
    teacher.parent = admin
    teacher.skip_confirmation!
    teacher.save!
    puts "[Sampler] Created teacher #{teacher.email} / #{password}"

    10.times do
      teacher.students.create!({
        :first_name => Faker::Name.first_name,
        :last_name => Faker::Name.last_name,
        :birthday => Time.now - 16.years
      })
    end
  rescue Exception => e
    puts "[Sampler] Error in creating sample teacher: #{e.inspect}"
  end
end
