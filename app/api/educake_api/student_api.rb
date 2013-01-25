module EducakeAPI
  class StudentAPI < Grape::API
    resource :students do
      desc "Get list students"
      params do
        optional :page_size, :type => Integer, :desc => "Size for pagination"
        optional :page_id, :type => Integer, :desc => "Page index"
      end      
      get "/" do
        @students = current_user.accessible_students.load_data(filtered_params)
        @current_page = check_page_id(@students.total_pages)
        {:data => @students, :total_pages => @students.total_pages, :current_page => @current_page}
      end
    end
  end
end
