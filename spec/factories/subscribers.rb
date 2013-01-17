# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscriber do
    sequence(:email) { |n| "name#{n}@gmail.com"}
  end
end
