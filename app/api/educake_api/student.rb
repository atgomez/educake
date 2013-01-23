module EducakeAPI
  class Student < Grape::API
    resource :students do
      desc "Get list students"
      get "/" do        
        # TODO: implement this API
        {}
      end
    end
  end
end
