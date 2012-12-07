FactoryGirl.define do
  factory :student do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birthday { Time.now - 16.years }
    association :teacher, :factory => :teacher
  end
end
