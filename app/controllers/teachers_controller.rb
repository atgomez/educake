class TeachersController < ApplicationController
  layout "common"

  check_authorization
  authorize_resource :user

  def index
    @students = current_user.accessible_students.load_data(filtered_params)
    series = []
    students = current_user.accessible_students
    students.map do |student|
      series += student.goals_statuses
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
    @students = current_user.accessible_students.order("first_name ASC, last_name ASC")
  end
  
  def show_charts 
    @series = []
    @students = current_user.accessible_students.includes(:goals)
    @students.map do |student|
      goals_statuses = student.goals_statuses
      @series << {
        :name => student.full_name,
        :data => goals_statuses,
        :yAxis => 2
      } unless goals_statuses.empty?
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
