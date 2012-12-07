FactoryGirl.define do
  factory :grade do
    due_date { Time.now + 20.days }
    accuracy { rand(20) + 20 }
    note { Faker::Lorem::paragraphs }
  end
end