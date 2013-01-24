module EducakeAPI
  class StudentAPI < Grape::API
    resource :students do
      desc "Get list students"
      get "/" do
        @students = current_user.accessible_students.load_data(filtered_params)
        @current_page = filtered_params[:page_id] || 1
        {:data => @students, :total_pages => @students.total_pages, :current_page => @current_page}
      end
    end
  end
end
