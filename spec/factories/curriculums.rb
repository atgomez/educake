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
end
