FactoryGirl.define do
  factory :user, :class => User do
    sequence(:email) { |n| "sample-user#{n}@teacher.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password "123456"
    password_confirmation "123456"
    confirmed_at Time.now
  end

  factory :super_admin, :class => User do |u|
    u.sequence(:email) { |n| "super-admin#{n}@teacher.com" }
    u.first_name { Faker::Name.first_name }
    u.last_name { Faker::Name.last_name }
    u.password "123456"
    u.password_confirmation "123456"
    u.confirmed_at Time.now
    u.is_admin true
    #u.after_create do |user|
    #  user.is_admin = true
    #  user.save
    #end
  end

  factory :admin, :class => User do |u|
    u.sequence(:email) { |n| "admin#{n}@teacher.com" }
    u.first_name { Faker::Name.first_name }
    u.last_name { Faker::Name.last_name }
    u.password "123456"
    u.password_confirmation "123456"
    u.confirmed_at Time.now
    u.role { Role[:admin] }
    u.association :school
  end

  factory :teacher, :class => User do |u|
    u.sequence(:email) { |n| "teacher#{n}@teacher.com" }
    u.first_name { Faker::Name.first_name }
    u.last_name { Faker::Name.last_name }
    u.password "123456"
    u.password_confirmation "123456"
    u.confirmed_at Time.now
    u.association :parent, :factory => :admin
    u.role { Role[:teacher] }
    u.association :school
  end

  factory :parent, :class => User do |u|
    u.sequence(:email) { |n| "parent#{n}@teacher.com" }
    u.first_name { Faker::Name.first_name }
    u.last_name { Faker::Name.last_name }
    u.password "123456"
    u.password_confirmation "123456"
    u.confirmed_at Time.now
    u.association :parent, :factory => :admin
    u.role { Role[:parent] }
    u.association :school
  end
end

