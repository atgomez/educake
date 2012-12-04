class Admin::TeachersController < Admin::BaseAdminController
  cross_role_action :index, :show, :show_charts, :show_teachers_chart
  # TODO: improve this method, because it load teachers 2 times.
  def index
    @is_view_as = current_user.is_super_admin? && params[:user_id]
    if @is_view_as 
      @user = User.find params[:user_id]
    else
      @user = current_user
    end 
    @teachers = @user.children.teachers.unblocked.load_data(filtered_params)
    @all_teachers = @user.children.teachers.unblocked
    series = []
    @all_teachers.map do |teacher|
      teacher_status = teacher.teacher_status
      series << {
        :name => teacher.full_name,
        :data => teacher_status,
        :yAxis => 2
      } unless teacher_status.empty?
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

  # GET /admin/teachers/all
  # TODO: should apply endless pagination.
  def all
    @teachers = current_user.children.teachers.unblocked.order("first_name ASC, last_name ASC")
  end

  # GET /admin/teachers/:id/all_students
  # TODO: should apply endless pagination.
  def all_students
    if find_or_redirect
      @students = @teacher.accessible_students
    end
  end

  def create
    result = {}
    status_code = 201

    begin
      @teacher = current_user.children.new_with_role_name(:teacher, params[:user])
      @teacher.skip_password = true
      if @teacher.save
        status_code = 201
        result[:message] = I18n.t('admin.teacher.created_successfully')
        flash[:notice] = result[:message]
      else
        status_code = 400
        result[:message] = I18n.t('admin.teacher.create_failed')
        result[:html] = render_to_string(:partial => 'admin/teachers/form', 
                          :locals => {:teacher => @teacher})
      end
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::TeachersController#create")
      status_code = 400
      result[:message] = I18n.t('admin.teacher.create_failed')
    end

    render(:json => result, :status => status_code)
  end
  
  def show    
    if find_or_redirect
      session[:teacher_id] = params[:id]
      @students = @teacher.accessible_students.load_data(filtered_params)
      series = []

      @students.map do |student|
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
  end
  
  def show_charts 
    @series = []
    @teacher = find_or_redirect(session[:teacher_id])
    return if @teacher.blank?
    
    @students = @teacher.accessible_students.includes(:goals)
    @students.map do |student|
      goals_grades = student.goals_grades
      @series << {
        :name => student.full_name,
        :data => goals_grades,
        :yAxis => 2,
        :item_id => student.id,
        :url => admin_student_path(student)
      } unless goals_grades.empty?
    end
    @series = @series.to_json
    render :template => 'students/common_chart', :layout => "chart"
  end

  def show_teachers_chart
    @teacher = User.find_by_id params[:id]
    teachers = @teacher.children.teachers.unblocked
    @series = []
    teachers.map do |teacher|
      teacher_status = teacher.teacher_status
      @series << {
        :name => teacher.full_name,
        :data => teacher_status,
        :yAxis => 2,
        :item_id => teacher.id,
        :url => admin_teacher_path(teacher)
      } unless teacher_status.empty?
    end
    @series = @series.to_json
    render :template => 'students/common_chart', :layout => "chart"
  end

  # GET: /admin/teacher/search?query=<QUERY>
  # TODO: optimize this method
  def search
    query = params[:query]
    if query.blank?
      redirect_to(:action => 'index')
    else
      query.strip!

      case params[:type]
        when 'student' then
          @students = Student.students_of_teacher(current_user).search_data(query, filtered_params)
        when 'teacher' then
          @teachers = current_user.children.search_data(query, filtered_params)
        else
          @students = Student.students_of_teacher(current_user).search_data(query, filtered_params)
          @teachers = current_user.children.search_data(query, filtered_params)
      end
    end
  end

  def get_students
    teacher = current_user.children.teachers.unblocked.find_by_id(params[:teacher_id])
    @students = teacher.accessible_students
    render :partial => 'admin/teachers/get_students'
  end

  protected

    def set_current_tab
      @current_tab = 'classroom'
    end

    # Find record and redirect to index page if the record does not exist
    def find_or_redirect(teacher_id = params[:id])
      if current_user.is_super_admin?
        @teacher = User.find teacher_id
      else
        @teacher = current_user.children.teachers.unblocked.find_by_id(teacher_id)
      end 
      if @teacher.blank?
        respond_to do |format|
          format.html {
            flash[:alert] = I18n.t('admin.teacher.not_found') 
            redirect_to :action => 'index'
          }
        end
      end

      @teacher
    end
end
