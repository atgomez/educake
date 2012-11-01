class TeachersController < ApplicationController
  layout "common"

  check_authorization
  authorize_resource :user

  def index
    @students = current_user.students.load_data(filtered_params)

    student_ids = StudentSharing.where(:user_id => current_user.id).map(&:student_id)
    if student_ids.empty?
      @sharing_students = []
    else
      @sharing_students = Student.load_data(filtered_params, student_ids)
    end
  end
  
  def show_charts 
    @series = []
    @students = current_user.students.load_data(filtered_params)
    @students.map do |student|
      @series << {
        :name => student.full_name,
        :data => student.goals_statuses
      }
    end
    @series = @series.to_json
    render :template => 'students/common_chart', :layout => "chart"
  end
  
  protected

  def set_current_tab
    @current_tab = 'classroom'
  end
end
