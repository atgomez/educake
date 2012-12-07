FactoryGirl.define do
  factory :goal do
    due_date { Time.now + 1.years }
    baseline_date {Time.now - 30.days}
    accuracy { rand(50) + 50 }
    baseline { rand(50)}
    trial_days_actual {9}
    trial_days_total {10}
    description { Faker::Lorem::paragraphs }
  end
end