FactoryGirl.define do
  factory :access_token do
    client_application
    association :user, :factory => :teacher
    token {OAuth::Helper.generate_key(40)[0,40]}
    secret {OAuth::Helper.generate_key(40)[0,40]}
  end

  factory :oauth2_token, :class => "Oauth2Token", :parent => :access_token
end