class GoalsController < ApplicationController
  authorize_resource :goal, :grade
  cross_role_action :new_grade, :add_grade, :update_grade, :initial_import_grades, :import_grades,
                    :new, :edit, :create, :update, :destroy, :load_grades

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
      result[:message] = I18n.t('student.student_not_found')
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
      result[:message] = I18n.t('student.student_not_found')
      status_code = 400
    else
      @goal = @student.goals.find_by_id params[:id]
      if (@goal)
        #Remove id and student_id 
        params[:goal].delete :id
        params[:goal].delete :student_id
        check_time_update = @goal.updated_at.to_s
        before_checked = @goal.is_completed
        if (@goal.changed? && before_checked == true) || (params[:goal][:is_completed].to_i ==  1 && (before_checked == true))
          params[:goal][:is_completed] = false
        end 
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
        result[:message] = I18n.t('goal.not_found')
        status_code = 400
      end
    end
  
    render(:json => result, :status => status_code)
  end
  
  def new_grade 
    @grade = Grade.new
    @grade.due_date = Date.today
    student = Student.find(session[:student_id])
    if student 
      @goals = student.goals.incomplete.map{|g| [[g.subject.name, g.curriculum.name].join(" "), g.id]}
    end 
  end
  
  def add_grade
    result = {}
    status_code = 201
    student = Student.find(session[:student_id])
    if student 
      @goals = student.goals.incomplete.map{|g| [[g.subject.name, g.curriculum.name].join(" "), g.id]}
    end 

    @goal = Goal.incomplete.find_by_id(params[:grade][:goal_id])
    if (@goal)
      @grade = @goal.build_grade params[:grade]
      if (@grade)
        @grade = @goal.update_grade_state(@grade)
        if @grade.save
          @goal.update_all_grade
          status_code = 201
          result[:message] = I18n.t('grade.created_successfully')
          flash[:notice] = result[:message]
        else
          status_code = 400
          result[:message] = I18n.t('grade.save_failed')
          result[:html] = render_to_string(:partial => 'goals/form_grade')
        end
      else
        @grade = Grade.new params[:grade]
        @grade.errors.add(:due_date, "must be in range")
        status_code = 400
        result[:message] = I18n.t('grade.save_failed')
        result[:html] = render_to_string(:partial => 'goals/form_grade')
      end
    else
      @grade = Grade.new params[:grade]
      @grade.errors.add(:goal_id, "must be selected")
      status_code = 400
      result[:message] = I18n.t('grade.save_failed')
      result[:html] = render_to_string(:partial => 'goals/form_grade')
    end

    render(:json => result, :status => status_code)
  end

  def update_grade
    @goal = Goal.find(params[:id])
    if @goal.update_attribute(:is_completed, params[:grade])
      render(:json => {:message => I18n.t('goal.updated_successfully')}, :status => 200)
    else
      render(:json => {:message => I18n.t('goal.save_failed')}, :status => 400)
    end
  end

  def initial_import_grades
    @grade = Grade.new
    @student = Student.find(session[:student_id])
    @goals = []
    session[:student_id] = @student.id 
    if @student 
      @goals = @student.goals.incomplete.map{|g| [g.name, g.id]}
    end
  end
  
  def import_grades
    @format_csv = false
    @student = Student.find params[:student_id]
    @goals = @student.goals.incomplete.map{|g| [g.name, g.id]}
    @goal = Goal.find_by_id params[:goal][:id]
    @file_import = params[:goal][:grades]
    errors = []
    if @goal
      invalid_grade = false
      unless @file_import.nil?
        @format_csv = @file_import.original_filename.include?(".csv")

        if @format_csv
          grades = @goal.parse_csv(@file_import.path)
          Grade.transaction do 
            grades.map do |grade|
              day = grade[:due_date].split("/")
              day = [day[1], day[0], day[2]].join("/")
              grade[:due_date] = Date.parse day
              build_grade = @goal.build_grade(grade, true)
              
              if (build_grade)
                build_grade = @goal.update_grade_state(build_grade)
                if build_grade.save
                  build_grade.update_attribute(:user_id, current_user.id)
                  flash[:notice] = I18n.t('grade.import_successfully')
                else
                  invalid_grade = true
                  key_errors = build_grade.errors.messages.keys
                  error = ""
                  key_errors.each do |key|
                    error = build_grade[key].to_s + " " + build_grade.errors.messages[key].first
                  end
                  errors << error
                end
              end
            end
          end
        end
        if invalid_grade
          flash[:notice] = nil
          flash[:alert] = Grade.show_errors(I18n.t('grade.save_failed'), errors) 
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
    redirect_link = params[:redirect_link]
    if redirect_link.blank?
      if params[:student_id].blank?
        redirect_link = students_path
      else
        redirect_link = edit_student_path(params[:student_id])
      end
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
  
  def load_grades
    goal = Goal.find_by_id params[:goal_id]
    grades = goal.grades.order('due_date ASC').load_data(filtered_params)
    render :partial => "shared/load_grades", :locals => {:grades => grades}
  end 
  
end
