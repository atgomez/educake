class Admin::TeachersController < Admin::BaseAdminController
  layout "common"
  
  def index
    @teachers = current_user.children.load_data(filtered_params).includes(:students)
  end

  def create
    result = {}
    status_code = 201

    begin
      @teacher = current_user.children.new_with_default_password(params[:user])
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
    @students = @teacher.students.load_data(filtered_params)
    student_ids = StudentSharing.where(:user_id => @teacher.id).map(&:student_id)
    if student_ids.empty?
      @sharing_students = []
    else
      @sharing_students = Student.load_data(filtered_params, student_ids)
    end
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

  protected

    def set_current_tab
      @current_tab = 'classroom'
    end
end
