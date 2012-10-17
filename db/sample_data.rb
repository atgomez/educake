# This file should contain dummy records creation needed to demonstrate the app or to test.
# The data can then be loaded with the rake db:sample_data.

admin = User.first

5.times do 
  begin
    teacher = User.new({
      :email => Faker::Internet.email,
      :first_name => Faker::Name.first_name,
      :last_name => Faker::Name.last_name,
      :password => "123456",
      :password_confirmation => "123456",
    })
    teacher.parent = admin
    teacher.skip_confirmation!
    teacher.save!
    puts "[Sampler] Created teacher #{teacher.email} / 123456"

    20.times do
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
Role.create(:name => "Teacher")
Role.create(:name => "Admin")
Role.create(:name => "Parent")

