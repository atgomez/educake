FactoryGirl.define do
  factory :student_sharing do
    sequence(:email) { |n| "sample-user#{n}@teacher.com" }
    sequence(:first_name) { |n| "First name#{n}" }
    sequence(:last_name) { |n| "Last name#{n}" }
    student
    role {Role[:teacher]}
    sequence(:confirm_token) { |n| "abcdef1234-{n}" }
  end
end
