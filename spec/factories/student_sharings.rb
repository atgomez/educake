FactoryGirl.define do
  factory :student_sharing do
    sequence(:email) { |n| "sample-user#{n}@teacher.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    student
    role {Role[:teacher]}
    sequence(:confirm_token) { |n| "abcdef1234-{n}" }
  end
end
