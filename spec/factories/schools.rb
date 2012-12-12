FactoryGirl.define do
  factory :school do
    sequence(:name) { |n| "School#{n}" }
    city { Faker::Address.city }
    state { Faker::Address.state }
    address1 { Faker::Address.street_address }
    phone { Faker::PhoneNumber.phone_number }
    zipcode { Faker::Address.zip.slice(0, 5) }

    after(:create) do |school, evaluator|
      FactoryGirl.create(:admin, :school => school)
    end
  end
end
