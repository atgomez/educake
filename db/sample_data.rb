# This file should contain dummy records creation needed to demonstrate the app or to test.
# The data can then be loaded with the rake db:sample_data.

# ===================================================================================
# Create sample Curriculums
# ===================================================================================

cores = {}
CurriculumCore.all.each do |item|
  cores[item.name] = item.id
end

subjects = {}
Subject.all.each do |item|
  subjects[item.name] = item.id
end

grades = {}
CurriculumGrade.all.each do |item|
  grades[item.name] = item.id
end

areas = {}
CurriculumArea.all.each do |item|
  areas[item.name] = item.id
end

# Curriculum
[
  {
    :curriculum_core => "Common Core",
    :subject => "MATH",
    :curriculum_grade => "2",
    :curriculum_area => "OA",
    :standard => "2",
    :description1 => "Represent and solve problems involving addition and subtraction",
    :description2 => "Use addition and subtraction within 100 to solve one- and two-step word problems involving situations of adding to, taking from, putting together, taking apart, and comparing, with unknowns in all positions, e.g., by using drawings and equations with a symbol for the unknown number to represent the problem."
  },

  {
    :curriculum_core => "Common Core",
    :subject => "ELA",
    :curriculum_grade => "2",
    :curriculum_area => "W",
    :standard => "1",
    :description1 => "Text Types and Purposes",
    :description2 => "Write opinion pieces in which they introduce the topic or book they are writing about, state an opinion, supply reasons that support the opinion, use linking words (e.g., because, and, also) to connect opinion and reasons, and provide a concluding statement or section."
  }
].each do |data|
  Curriculum.create!(
    :curriculum_core_id => cores[data[:curriculum_core]],
    :subject_id => subjects[data[:subject]],
    :curriculum_grade_id => grades[data[:curriculum_grade]],
    :curriculum_area_id => areas[data[:curriculum_area]],
    :standard => data[:standard],
    :description1 => data[:description1],
    :description2 => data[:description2]
  )
end

# ===================================================================================
# Create sample School, Admin, Teachers, Students, Goals and Grades
# ===================================================================================

@curriculums = Curriculum.all

def create_sample_students(teacher)
  Goal.transaction do
    5.times do
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      # puts "Student name: #{first_name} #{last_name}"
      student = teacher.students.create!({
        :first_name => first_name,
        :last_name => last_name,
        :birthday => (Time.now - 16.years).to_date
      })

      # Create goals
      2.times do |t|
        baseline = rand(30)
        accuracy = baseline + 50

        goal = student.goals.create(
          :curriculum_id => @curriculums[t].id, 
          :baseline_date => (Time.now - 6.months).to_date,
          :due_date => (Time.now + 6.months).to_date,
          :description => Faker::Lorem.sentence(10),
          :baseline => baseline,
          :accuracy => accuracy,          
          :trial_days_actual => 9,
          :trial_days_total => 10
        )

        # Create grade for goal
        15.times do |grade_t|
          accuracy = goal.baseline + 1          
          if grade_t > 0
            accuracy = (10 .. 100).to_a.sample
          end

          grade = goal.build_grade({
            :due_date => (goal.baseline_date + grade_t.days).to_date,
            :accuracy => accuracy,
            :user_id => teacher.id,
            :time_to_complete => "0#{rand(5)}:00",
            :note => Faker::Lorem.sentence(5)
          })

          grade = goal.update_grade_state(grade)
          grade.save
        end
      end
    end
  end
end

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

create_sample_students(teacher)

User.transaction do
  5.times do 
    begin
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      # puts "Teacher name: #{first_name} #{last_name}"
      teacher = User.new({
        :email => Faker::Internet.email,
        :first_name => first_name,
        :last_name => last_name,
        :password => "123456",
        :password_confirmation => "123456",
        :school_id => school.id
      })
      teacher.role = teacher_role
      teacher.parent = admin
      teacher.skip_confirmation!
      teacher.save!
      puts "[Sampler] Created teacher #{teacher.email} / #{password}"

      create_sample_students(teacher)
    rescue Exception => e
      puts "[Sampler] Error in creating sample teacher: #{e.inspect}"
    end
  end
end
