# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :curriculum_core do
    sequence(:name) { |n| "CCore#{n}" }
  end
end
