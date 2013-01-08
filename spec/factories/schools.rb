FactoryGirl.define do
  factory :school do
    name { Faker::Company.name }
    city { Faker::Address.city }
    state { Faker::Address.state }
    address1 { Faker::Address.street_address }
    phone { Faker::PhoneNumber.phone_number }
    zipcode { Faker::Address.zip.slice(0, 5) }

    #factory :school_with_admin do
      after(:create) do |school, evaluator|
        FactoryGirl.create(:admin, :school => school)
      end
    #end
  end
end
