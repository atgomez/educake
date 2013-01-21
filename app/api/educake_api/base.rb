module EducakeAPI
  class Base < Grape::API
    prefix "api"
    format :json
    version "v1"
    # Use Rabl is optional
    # formatter :json, Grape::Formatter::Rabl
  end
end
