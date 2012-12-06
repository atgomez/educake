FactoryGirl.define do
  factory :curriculum do
    sequence(:name) { |n| "Curriculum #{n}" }
  end
end
