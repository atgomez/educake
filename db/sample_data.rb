# This file should contain dummy records creation needed to demonstrate the app or to test.
# The data can then be loaded with the rake db:sample_data.

5.times do 
  begin
    teacher = User.create!({
      :email => Faker::Internet.email,
      :first_name => Faker::Name.first_name,
      :last_name => Faker::Name.last_name,
      :password => "123456",
      :password_confirmation => "123456"
    })
    puts "[Sampler] Created teacher #{teacher.email} / 123456"

    25.times do
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