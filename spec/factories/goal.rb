FactoryGirl.define do
  factory :goal do
    due_date { Time.now + 1.years }
    baseline_date {Time.now - 30.days}
    accuracy { rand(50) + 50 }
    baseline { rand(50)}
    trial_days_actual {9}
    trial_days_total {10}
    description { Faker::Lorem::paragraphs }

    factory :valid_goal, :class => Goal do
      curriculum
      subject
    end

    # Build Goal with two grades
    factory :goal_with_grades, :parent => :valid_goal do
      after(:create) do |goal, evaluator|
        FactoryGirl.create(:grade, :due_date => Time.now - 1.days, :goal => goal)
        FactoryGirl.build(:grade, :due_date => Time.now - 2.days, :goal => goal)
      end
    end
  end
end
