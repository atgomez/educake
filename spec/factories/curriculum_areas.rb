# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :curriculum_area do
    sequence(:name) { |n| "Area#{n}" }
  end
end
