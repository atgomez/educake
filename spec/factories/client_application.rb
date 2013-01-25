FactoryGirl.define do 
	factory :client_application do 
		name "Test"
		url "http://localhost:4567"
		support_url ""
		callback_url "http://localhost:4567/auth/test/callback"
		association :user, :factory => :teacher
	end
end 