class GoalsController < ApplicationController
  def create
    result = {}
    status_code = 201

    @student = Student.find_by_id(params[:student_id])

    if @student.blank?
      result[:message] = I18n.t('goal.student_not_found')
      status_code = 400
    else
      @goal = @student.goals.new(params[:goal])
      if @goal.save
        status_code = 201
        result[:message] = I18n.t('goal.created_successfully')
        flash[:notice] = result[:message]
      else
        @goal.build_statuses if @goal.statuses.blank?

        status_code = 400
        result[:message] = I18n.t('goal.save_failed')
        result[:html] = render_to_string(:partial => 'goals/form', 
                          :locals => {:student => @student, :goal => @goal})
      end
    end

    render(:json => result, :status => status_code)
  end
  
  def new_status 
    @status = Status.new
    student = Student.find(session[:student_id])
    if student 
      @goals = student.goals.map{|g| [[g.subject.name, g.curriculum.name].join(" "), g.id]}
    end 
  end 
  def add_status
    @status = Status.new params[:status]
    @status.save 
  end
end
