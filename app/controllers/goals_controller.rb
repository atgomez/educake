class GoalsController < ApplicationController
  def create
    result = {}
    status_code = 201

    @student = Student.find_by_id(params[:goal][:student_id])

    if @student.blank?
      result[:message] = I18n.t('goal.student_not_found')
      status_code = 400
    else
      #Remove id and student_id 
      params[:goal].delete :id
      params[:goal].delete :student_id
      @goal = @student.goals.new(params[:goal])
      if @goal.save
        status_code = 201
        result[:message] = I18n.t('goal.created_successfully')
        flash[:notice] = result[:message]
      else
        status_code = 400
        result[:message] = I18n.t('goal.save_failed')
        result[:html] = render_to_string(:partial => 'goals/form', 
                          :locals => {:student => @student, :goal => @goal})
      end
    end
  
    render(:json => result, :status => status_code)
  end

  def update
    result = {}
    status_code = 201

    @student = Student.find_by_id(params[:goal][:student_id])

    if @student.blank?
      result[:message] = I18n.t('goal.student_not_found')
      status_code = 400
    else
      @goal = @student.goals.find_by_id params[:id]
      if (@goal)
        #Remove id and student_id 
        params[:goal].delete :id
        params[:goal].delete :student_id
        if @goal.update_attributes params[:goal]
          status_code = 201
          result[:message] = I18n.t('goal.updated_successfully')
          flash[:notice] = result[:message]
        else
          status_code = 400
          result[:message] = I18n.t('goal.save_failed')
          result[:html] = render_to_string(:partial => 'goals/form', 
                            :locals => {:student => @student, :goal => @goal, :fail_to_update => true})
        end
      else
        result[:message] = I18n.t('goal.goal_not_found')
        status_code = 400
      end
    end
  
    render(:json => result, :status => status_code)
  end
  
  def new_status 
    @status = Status.new
    @status.due_date = Date.today
    student = Student.find(session[:student_id])
    if student 
      @goals = student.goals.map{|g| [[g.subject.name, g.curriculum.name].join(" "), g.id]}
    end 
  end
  
  def add_status
    result = {}
    status_code = 201

    student = Student.find(session[:student_id])
    if student 
      @goals = student.goals.map{|g| [[g.subject.name, g.curriculum.name].join(" "), g.id]}
    end 

    @goal = Goal.find_by_id(params[:status][:goal_id])
    if (@goal)
      @status = @goal.statuses.new params[:status]
      @status = @goal.update_status_state(@status)
      if @status.save 
        status_code = 201
        result[:message] = I18n.t('status.created_successfully')
        flash[:notice] = result[:message]
      else
        status_code = 400
        result[:message] = I18n.t('status.save_failed')
        result[:html] = render_to_string(:partial => 'goals/form_status')
      end
    else
      @status = Status.new params[:status]
      @status.errors.add(:goal_id, "must be selected")
      status_code = 400
      result[:message] = I18n.t('status.save_failed')
      result[:html] = render_to_string(:partial => 'goals/form_status')
    end

    render(:json => result, :status => status_code)
  end

  def update_status
    @goal = Goal.find(params[:id])
    if @goal.update_attribute(:is_completed, params[:status])
      render(:json => {:message => "Success"})
    else

    end
  end

end
