module EducakeAPI
  class All < Base
    # Mount other API classes.
    mount EducakeAPI::Goal
    mount EducakeAPI::Student
  end
end
