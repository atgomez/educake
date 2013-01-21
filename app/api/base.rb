module TeacherMgnt::API
  class Base < Grape::API
    prefix "api"
    format :json
    # Use Rabl is optional
    # formatter :json, Grape::Formatter::Rabl
  end
end
