class Admin::TeachersController < Admin::BaseAdminController
  def index
    @teachers = current_user.children.load_data(filtered_params).includes(:students)
    teachers = User.all
    series = []
    teachers.map do |teacher|
      series << {
        :name => teacher.full_name,
        :data => teacher.teacher_status
      } unless teacher.teacher_status.empty?
    end

    if series.empty?
      @width = "0%"
      @height = "0"
    else 
      @width = "100%"
      @height = "500"
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
    @teacher = User.find params[:id]
    session[:teacher_id] = params[:id]
    @students = @teacher.students.load_data(filtered_params)
    series = []
    @students.map do |student|
      series += student.goals_statuses
    end
    if series.empty?
      @width = "0%"
      @height = "0"
    else 
      @width = "100%"
      @height = "500"
    end 
    
    student_ids = StudentSharing.where(:user_id => @teacher.id).map(&:student_id)
    if student_ids.empty?
      @sharing_students = []
    else
      @sharing_students = Student.load_data(filtered_params, student_ids)
    end
  end
  
  def show_charts 
    @series = []
    @teacher = User.find session[:teacher_id]
    @students = @teacher.students.load_data(filtered_params)
    @students.map do |student|
      @series << {
        :name => student.full_name,
        :data => student.goals_statuses
      } unless student.goals_statuses.empty?
    end
    @series = @series.to_json
    render :template => 'students/common_chart', :layout => "chart"
  end

  def show_teachers_chart
    teachers = User.all
    @series = []
    teachers.map do |teacher|
      @series << {
        :name => teacher.full_name,
        :data => teacher.teacher_status
      } unless teacher.teacher_status.empty?
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
          @teachers = current_user.children.search_data(query, filtered_params).includes(:students)
        else
          @students = Student.students_of_teacher(current_user).search_data(query, filtered_params)
          @teachers = current_user.children.search_data(query, filtered_params).includes(:students)
      end
    end
  end

  def get_students
    teacher = User.find_by_id(params[:teacher_id])
    @students = teacher.students
    render :partial => 'admin/teachers/get_students'
  end

  protected

    def set_current_tab
      @current_tab = 'classroom'
    end
end
