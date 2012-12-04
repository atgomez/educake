class TeachersController < ApplicationController
  check_authorization
  authorize_resource :user

  def index
    @user = current_user
    @students = @user.accessible_students.load_data(filtered_params)
    series = []
    students = @user.accessible_students
    students.map do |student|
      series += student.goals_grades
    end
    if series.empty?
      @width = "0%"
      @height = "0"
    else 
      @width = "100%"
      @height = "500"
    end 

    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /teachers/all_students
  # TODO: should apply endless pagination.
  def all_students
    @students = current_user.accessible_students
  end
  
  def show_charts 
    @series = []
    @students = current_user.accessible_students.includes(:goals)
    @students.map do |student|
      goals_grades = student.goals_grades
      @series << {
        :name => student.full_name,
        :data => goals_grades,
        :yAxis => 2,
        :item_id => student.id,
        :url => student_path(student)
      } unless goals_grades.empty?
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
      8
    end
end
