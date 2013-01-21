module EducakeAPI
  class Student < Base
    resource :students do
      desc "Get list students"
      get "/" do
        {}
      end
    end
  end
end
