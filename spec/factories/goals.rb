FactoryGirl.define do
  factory :goal do
    trial_days_actual {9}
    trial_days_total {10}
    description { Faker::Lorem::paragraphs }

    factory :valid_goal, :class => Goal do
      curriculum
      subject
      student
    end

    # Build Goal with two grades
    factory :goal_with_grades, :parent => :valid_goal do
      after(:create) do |goal, evaluator|
        FactoryGirl.create(:grade, :due_date => Date.today - 1.days, :goal => goal)
        FactoryGirl.create(:grade, :due_date => Date.today - 2.days, :goal => goal)
      end
    end

    # Base on data example
    baseline_date { Date.parse '01/11/2012'}
    due_date { Date.parse '01/11/2013'}
    baseline { 20 }
    accuracy { 90 }
    

    # Dynamic data
    curriculum
    subject
    student
  end
end
