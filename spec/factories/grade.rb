FactoryGirl.define do
  factory :grade do
    note { Faker::Lorem::paragraphs }

    # Dynamic data
    due_date { due_date }
    accuracy { accuracy }
    goal
  end
end
