class Admin::TeachersController < Admin::BaseAdminController
  cross_role_action :index, :show, :all, :search, :get_students
  # TODO: improve this method, because it load teachers 2 times.
  def index
    if find_or_redirect
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
       puts "*"*20
       puts @teachers.inspect

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

  # GET /admin/teachers/all
  # TODO: should apply endless pagination.
  def all
    if find_or_redirect
      @teachers = @user.children.teachers.unblocked.order("first_name ASC, last_name ASC")
      @series = []
      @teachers.map do |teacher|
        teacher_status = teacher.teacher_status
        @series << {
          :name => teacher.full_name,
          :data => teacher_status,
          :yAxis => 2
        } unless teacher_status.empty?
      end
    end
  end

  def create
    if find_or_redirect
      result = {}
      status_code = 201

      begin
        @teacher = @user.children.new_with_role_name(:teacher, params[:user])
        @teacher.skip_password!
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
  end
  
  def update
    if find_or_redirect
      result = {}
      status_code = 201

      begin
        @teacher = @user.children.find params[:id]
        @teacher.skip_password!
        if @teacher.update_attributes(params[:user])
          status_code = 201
          result[:message] = I18n.t('admin.teacher.updated_successfully')
          flash[:notice] = result[:message]
        else
          status_code = 400
          result[:message] = I18n.t('admin.teacher.updated_failed')
          result[:html] = render_to_string(:partial => 'admin/teachers/form', 
                            :locals => {:teacher => @teacher})
        end
      rescue Exception => exc
        ::Util.log_error(exc, "Admin::TeachersController#update")
        status_code = 400
        result[:message] = I18n.t('admin.teacher.updated_failed')
      end

      render(:json => result, :status => status_code)
    end
  end 

  # GET: /admin/teacher/search?query=<QUERY>
  # TODO: optimize this method
  def search
    if find_or_redirect
      query = params[:query]
      if query.blank?
        redirect_to(:action => 'index')
      else
        query.strip!

        case params[:type]
          when 'student' then
            @students = Student.students_of_teacher(@user).search_data(query, filtered_params)
          when 'teacher' then
            @teachers = @user.children.search_data(query, filtered_params)
          else
            @students = Student.students_of_teacher(@user).search_data(query, filtered_params)
            @teachers = @user.children.search_data(query, filtered_params)
        end
      end
    end
  end

  def get_students
    if find_or_redirect
      teacher = @user.children.teachers.unblocked.find_by_id(params[:teacher_id])
      @students = teacher.accessible_students
      render :partial => 'admin/teachers/get_students'
    end
  end

  def destroy
    if find_or_redirect
      @teacher = @user.children.teachers.unblocked.find(params[:id])
      @teacher.destroy
      
      redirect_to admin_teachers_path(:user_id => @user.id)
    end
  end
  
  protected

    def set_current_tab
      @current_tab = 'classroom'
    end

    # Find record and redirect to index page if the record does not exist
    # If current_user is Super Admin
    #   Get user admin via user_id
    # else
    #   Get user admin via current_user
    # Get teacher from id
    #

    def find_or_redirect(teacher_id = params[:id])
      if current_user.is_super_admin?
        @user = User.unblocked.find_by_id params[:user_id]
      else
        @user = current_user
      end
      @teacher = @user.children.teachers.unblocked.find_by_id(teacher_id)
      @current_user = current_user

      if !@user
        render_page_not_found
        return false
      end

      return true
    end
end
