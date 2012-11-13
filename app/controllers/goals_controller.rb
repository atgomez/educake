class GoalsController < ApplicationController
  def new
    @student = Student.find_by_id(params[:student_id])
  end

  def edit
    @student = Student.find_by_id(params[:student_id])
    @goal = Goal.find_by_id(params[:id])
  end

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
        check_time_update = @goal.updated_at.to_s
        before_checked = @goal.is_completed
        if @goal.update_attributes params[:goal]
          status_code = 201
          result[:message] = I18n.t('goal.updated_successfully')
          flash[:notice] = result[:message]
          after_updated_at =  @goal.updated_at.to_s
          if (check_time_update != after_updated_at && before_checked != false) || (params[:goal][:is_completed].to_i ==  1 && (before_checked == true))
            @goal.update_attribute(:is_completed, false)
          end 
        else
          status_code = 400
          result[:message] = I18n.t('goal.save_failed')
          result[:html] = render_to_string(:partial => 'goals/form', 
                            :locals => {:student => @student, :goal => @goal, :fail_to_update => true})
        end
      else
        result[:message] = I18n.t('goal.not_found')
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
      @goals = student.goals.available.map{|g| [[g.subject.name, g.curriculum.name].join(" "), g.id]}
    end 
  end
  
  def add_status
    result = {}
    status_code = 201
    student = Student.find(session[:student_id])
    if student 
      @goals = student.goals.available.map{|g| [[g.subject.name, g.curriculum.name].join(" "), g.id]}
    end 

    @goal = Goal.available.find_by_id(params[:status][:goal_id])
    if (@goal)
      @status = @goal.build_status params[:status]
      if (@status)
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
        @status.errors.add(:due_date, "must be in range")
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

  def initial_import_grades
    @status = Status.new
    @student = Student.find(session[:student_id])
    @goals = []
    session[:student_id] = @student.id 
    if @student 
      @goals = @student.goals.incomplete.is_archived(false).map{|g| [g.name, g.id]}
    end
  end
  
  def import_grades
    @format_csv = false
    @student = Student.find params[:student_id]
    @goals = @student.goals.incomplete.is_archived(false).map{|g| [g.name, g.id]}
    @goal = Goal.find_by_id params[:goal][:id]
    @file_import = params[:goal][:grades]
    if @goal
      invalid_grade = false
      unless @file_import.nil?
        @format_csv = @file_import.original_filename.include?".csv"
        if @format_csv
          @goal.update_attribute(:grades, @file_import)
          statuses = @goal.parse_csv(@goal.grades.url.split("?")[0])
          statuses.map do |status|
            day = status[:due_date].split("/")
            day = [day[1], day[0], day[2]].join("/")
            status[:due_date] = Date.parse day
            build_status = @goal.build_status(status, true)
            
            if (build_status)
              build_status = @goal.update_status_state(build_status)
              if build_status.save
                build_status.update_attribute(:user_id, current_user.id)
                flash[:notice] = I18n.t('status.import_successfully')
              else
                invalid_grade = true
              end
            end
          end
        end
        if invalid_grade
          flash[:notice] = nil
          flash[:alert] = I18n.t('status.save_failed')
        end
      end
    end
    respond_to do |format|
      format.js
    end 
  end

  # DELETE /goals/:id
  def destroy
    goal = Goal.find_by_id(params[:id])

    # Select the correct redirect URL
    if params[:student_id].blank?
      redirect_link = students_path
    else
      redirect_link = student_path(params[:student_id])
    end

    # Process the deleting
    if goal.blank?
      flash[:alert] = I18n.t('goal.not_found')     
    elsif goal.destroy
      flash[:notice] = I18n.t('goal.delete_successfully')      
    else
      flash[:alert] = I18n.t('goal.delete_failed')
    end

    # Render result
    redirect_to(redirect_link)
  end
end
