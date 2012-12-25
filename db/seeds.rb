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

# CurriculumCore
["Common Core"].each do |name|
  CurriculumCore.create!(:name => name)
end

# Create seed Subjects
["MATH", "ELA"].each do |name|
  Subject.create!(:name => name)
end

# CurriculumGrade
["2"].each do |name|
  CurriculumGrade.create!(:name => name)
end

# CurriculumArea
["OA", "NBT", "W", "L"].each do |name|
  CurriculumArea.create!(:name => name)
end

#
# Create Curriculum
#
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
