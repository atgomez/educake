module EducakeAPI
  class All < Grape::API
    prefix "api"
    format :json
    version "v1"
    rescue_from :all
    
    # Using Rabl is optional
    formatter :json, Grape::Formatter::Rabl   

    # Helpers
    helpers EducakeAPI::Helpers::Authentication
    helpers EducakeAPI::Helpers::FilterParams

    # Validators
    Grape::Validations.register_validator("api_date", EducakeAPI::Validators::APIDate)

    before do
      authenticate_user
      do_filter_params
    end

    # Mount other API classes.
    mount EducakeAPI::GoalAPI
    mount EducakeAPI::StudentAPI
  end
end
