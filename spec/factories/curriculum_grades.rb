# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :curriculum_grade do
    sequence(:name) { |n| "Grade#{n}" }
  end
end
