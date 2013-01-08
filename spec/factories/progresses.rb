FactoryGirl.define do
  factory :progress do
    accuracy { rand(100) }
    goal
    before(:create) do |p, evaluator|
      p.due_date = p.goal.baseline_date + 1.days
    end
  end
end
