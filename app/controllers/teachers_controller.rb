class TeachersController < ApplicationController
  layout "common"

  check_authorization
  authorize_resource :user

  def index
    @students = current_user.students.load_data(filtered_params)
    series = []
    @students.map do |student|
      series += student.goals_statuses
    end
    if series.empty?
      @width = "0%"
      @height = "0"
    else 
      @width = "100%"
      @height = "500"
    end 
    student_ids = StudentSharing.where(:user_id => current_user.id).map(&:student_id)
    if student_ids.empty?
      @sharing_students = []
    else
      @sharing_students = Student.load_data(filtered_params, student_ids)
    end
  end
  
  def show_charts 
    @series = []
    @students = current_user.students
    @students.map do |student|
      @series << {
        :name => student.full_name,
        :data => student.goals_statuses,
        :yAxis => 2
      } unless student.goals_statuses.empty?
    end
    @series = @series.to_json
    render :template => 'students/common_chart', :layout => "chart"
  end
  
  protected

  def set_current_tab
    @current_tab = 'classroom'
  end

  # You can override this method in the sub class.
  def default_page_size
    6
  end
end
