module EducakeAPI
  class All < Grape::API
    prefix "api"
    format :json
    version "v1"
    # Use Rabl is optional
    # formatter :json, Grape::Formatter::Rabl

    # Helper
    helpers EducakeAPI::Helpers::Authentication

    before do
      authenticate_user
    end

    # Mount other API classes.
    mount EducakeAPI::Goal
    mount EducakeAPI::Student
  end
end
