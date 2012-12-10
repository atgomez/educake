FactoryGirl.define do
  factory :grade do
    note { Faker::Lorem::paragraphs }

    # Dynamic data
    due_date { due_date }
    accuracy { rand(100) } # Fix stack level too deep error
    goal
  end
end
