FactoryGirl.define do
  factory :curriculum do
    curriculum_core
    subject
    curriculum_grade
    curriculum_area
    sequence(:standard) { |n| "#{n}" }
    description1 {Faker::Lorem.sentence(10)}
    description2 {Faker::Lorem.paragraph(2)}
  end

  factory :fixed_curriculum, :class => Curriculum do    
    standard "2"
    description1 {Faker::Lorem.sentence(10)}
    description2 {Faker::Lorem.paragraph(2)}
    after(:build) do |cur|
      core = CurriculumCore.find_or_initialize_by_name("Common Core")
      core.save
      cur.curriculum_core = core

      subject = Subject.find_or_initialize_by_name("MATH")
      subject.save
      cur.subject = subject
      
      grade = CurriculumGrade.find_or_initialize_by_name("2")
      grade.save
      cur.curriculum_grade = grade
      
      area = CurriculumArea.find_or_initialize_by_name("OA")
      area.save
      cur.curriculum_area = area
    end
  end
end
