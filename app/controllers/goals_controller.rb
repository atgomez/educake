class GoalsController < ApplicationController
  parent_actions = [:new_grade, :add_grade, :update_grade, :initial_import_grades, :import_grades, :load_grades]
  authorize_resource :goal, :except => parent_actions
  authorize_resource :grade, :only => parent_actions

  def new
    @goal ||= Goal.build_goal :trial_days_total => 10, :trial_days_actual => 9, :baseline_date => Date.today
    @student = Student.find_by_id(params[:student_id])
  end

  def edit
    @student = Student.find_by_id(params[:student_id])
    @goal = Goal.find_by_id(params[:id])
    @goal.build_progresses
  end

  def create
    @student = Student.find_by_id(params[:goal][:student_id])
    @goal_type = params[:goal][:is_percentage]
    
    params[:goal].delete :id
    params[:goal].delete :student_id
    @goal = @student.goals.new(params[:goal])
    @goal.save
  end

  def update
    @student = Student.find_by_id(params[:goal][:student_id])
    @goal = @student.goals.find_by_id params[:id]
    @goal_type = params[:goal][:is_percentage]
    if (@goal)
      #Remove id and student_id 
      params[:goal].delete :id
      params[:goal].delete :student_id
      before_checked = @goal.is_completed
      if (@goal.changed? && before_checked == true) || (params[:goal][:is_completed].to_i ==  1 && (before_checked == true))
        params[:goal][:is_completed] = false
      end 
      if @goal.update_attributes params[:goal]
        flash[:notice] = I18n.t('goal.updated_successfully')
      end
    else
      flash[:notice] = I18n.t('goal.not_found')
    end
  end
  
  def new_grade
    if find_user
      @grade = Grade.new
      @grade.due_date = Date.today
      @student = @user.accessible_students.find_by_id(params[:student_id])

      if is_mobile_request?
        @students = @user.accessible_students
        @student = @students.first
      end

      if @student 
        @goals = @student.goals.incomplete.map{|g| [g.name, g.id]}

        if is_mobile_request?
          # Clear the default student
          @student = nil
        end
        @goals = @student.goals.incomplete.map{|g| [g.name, g.id, {:goal_type => g.is_percentage}]}
      else
        render_page_not_found(I18n.t("student.student_not_found"))
      end 
    end
  end
  
  def add_grade
    if find_user
      @student = @user.accessible_students.find_by_id(params[:student_id])
      if @student 
        @goals = @student.goals.incomplete.map{|g| [g.name, g.id, {:goal_type => g.is_percentage}]}
      end 
     
      @goal = Goal.incomplete.find_by_id(params[:grade][:goal_id])
      @goal_type = @goal.is_percentage if @goal
      
      if (@goal)
        # Simple validation
        valid_grade = Grade.new params[:grade]
        unless valid_grade.valid?
          @grade = valid_grade
        else
          @grade = @goal.build_grade params[:grade]          
          if (@grade)
            @grade.user = @user
            @grade = @goal.update_grade_state(@grade)
            if @grade.save
              @goal.update_all_grade
              flash[:notice] = I18n.t('grade.created_successfully')
            end
          end
        end
      else
        @grade = Grade.new params[:grade]
        @grade.errors.add(:goal_id, :not_selected)
      end
    else
      flash[:warning] = I18n.t("common.error_unauthorized")
    end

    if @grade.new_record? && is_mobile_request?
      # Load students for mobile view.
      @students = @user.accessible_students
    elsif is_mobile_request?
      # TODO: change this.
      redirect_to(:action => "new_grade")
    end
  end

  # GET /goals/load_goals
  def load_goals
    if find_user
      @student = @user.accessible_students.find_by_id(params[:student_id])
      if @student 
        @goals = @student.goals.incomplete
      end
    end
  end

  def update_grade
    @goal = Goal.find_by_id(params[:id])
    if @goal && @goal.update_attribute(:is_completed, params[:grade])
      render(:json => {:message => I18n.t('goal.updated_successfully')}, :status => 200)
    else
      render(:json => {:message => I18n.t('goal.save_failed')}, :status => 400)
    end
  end

  def initial_import_grades
    @grade = Grade.new
    @student = Student.find(params[:student_id])
    @goals = []
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
                    error = build_grade[key].to_s 
                  end
                  errors << error
                end
              end
            end
          end
        end
        if invalid_grade
          flash[:notice] = nil
          flash[:alert] = show_errors(I18n.t('grade.save_failed'), errors) 
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

  # GET /goals/curriculum_info
  def curriculum_info
    result = {}
    begin
      unless params[:current_param_name].blank?
        # Find other association info
        field_name = params[:current_param_name]
        field_value = params[:goal][:curriculum_attributes][field_name]
        result[:extra_info] = Curriculum.get_associations_by_field(field_name, field_value)
      end

      curriculum = Curriculum.where(params[:goal][:curriculum_attributes]).first
      if curriculum.blank? && !result[:extra_info].blank?
        # Get the curriculum from the extra info
        curriculum = result[:extra_info].delete(:curriculum)
      end

      if curriculum
        result[:curriculum] = curriculum       
      else
        result = {:error => I18n.t("curriculum.not_found")}
      end
    rescue Exception => exc
      ::Util.log_error(exc, "GoalsController#curriculum_info")
      result = {:error => I18n.t("curriculum.not_found")}
    end

    render(:json => result)
  end

  protected

    def find_user
      parse_params_to_get_users

      if !(can? :view, @user)
        render_unauthorized
        return false
      end
      return true
    end

    def show_errors(message, errors)
      html = ""
      msgs = errors.slice(0, 4)
      html << "<div>"+message+"</div>"
      html << "<div>"+I18n.t("grade.msg_failed")+"</div>"
      msgs.map do |msg|
        html << "<div>"+msg+"</div>"
      end
      html << "<div>"+I18n.t("grade.msg_failed1")+"</div>"
      return html.html_safe
    end 
  
end
