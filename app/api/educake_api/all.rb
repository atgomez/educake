module EducakeAPI
  class All < Grape::API
    prefix "api"
    format :json
    version "v1"
    # Using Rabl is optional
    formatter :json, Grape::Formatter::Rabl   

    # Helper
    helpers EducakeAPI::Helpers::Authentication
    helpers EducakeAPI::Helpers::FilterParams

    before do
      authenticate_user
      do_filter_params
    end

    # Mount other API classes.
    mount EducakeAPI::GoalAPI
    mount EducakeAPI::StudentAPI
  end
end
