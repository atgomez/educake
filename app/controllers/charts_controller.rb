class ChartsController < ApplicationController
	# This controller need user_id in all cases
	# 
  cross_role_action :user_chart, :student_chart, :goal_chart

	# GET /charts/user_chart
  # Params:
  # user_id: ID of admin/teacher/parent
  # 
  # Render: The chart for @user
  # Note: Base on @user and current_user to decide which kind of chart for rendering

  def user_chart
  	if find_and_check_user
      render_chart(@user.series_json params, self)
  	end
  end

  # GET /charts/student_chart
  # Params:
  # student_id: ID of student
  # 
  # Render: The chart of a student with goals of the student

  def student_chart
    @student = Student.find_by_id params[:student_id]
    if @student
      @user = @student.teacher
    	if (can? :view_chart, @user)
        # start rendering here
        render_chart(@student.series_json params)
      else
        render_unauthorized
    	end
    else
      render_unauthorized
    end
  end

  # GET /charts/goal_chart
  # Params:
  # goal_id: ID of goal
  #
  # Render: The chart of particular goal

  def goal_chart
    @goal = Goal.find_by_id params[:goal_id]
    if @goal
      @user = @goal.student.teacher
    	if (can? :view_chart, @user)
        render_chart(@goal.series_json params)
	    else
	    	render_unauthorized
	    end
    else
      render_unauthorized
    end
  end

  protected
  	def find_and_check_user
  		@user = User.find_by_id(params[:user_id])
      render_unauthorized if (!@user || !(can? :view_chart, @user))
      return (@user && (can? :view_chart, @user))
  	end

  	def get_chart_data(user)
  		
  	end

    def render_chart(series)
      @series = series
      render :template => 'charts/common_chart', :layout => "chart"
    end
end
