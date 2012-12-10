FactoryGirl.define do
  factory :progress do
    due_date { due_date }
    accuracy { accuracy }
    goal
  end
end
