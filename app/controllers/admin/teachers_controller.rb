class Admin::TeachersController < Admin::BaseAdminController
  cross_role_action :index, :show, :new, :edit, :create, :update, :destroy, :all, :search, :get_students
  before_filter :find_user

  # TODO: improve this method, because it load teachers 2 times.
  def index
    @teachers = @admin.children.unblocked.load_data(filtered_params)

    unless request.xhr?
      # Only run here if not ajax request
      @all_teachers = @admin.children.unblocked.order(User::DEFAULT_ORDER)
      series = []

      # Options for export select box
      @all_teachers_collection = []

      @all_teachers.each do |teacher|
        if series.blank?
          # Only need ONE serie to detect the width and height of the chart.
          teacher_status = teacher.teacher_status
          series << {
            :name => teacher.full_name,
            :data => teacher_status,
            :yAxis => 2
          } unless teacher_status.empty?
        end

        # Prepare options for export popup
        @all_teachers_collection << [teacher.full_name, teacher.id]
      end

      @all_teachers_count = @all_teachers.length

      if series.empty?
        @width = "0%"
        @height = "0"
      else 
        @width = "100%"
        @height = "500"
      end
    end
    
    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /admin/teachers/all
  # TODO: should apply endless pagination.
  def all
    @teachers = @admin.children.unblocked.order(User::DEFAULT_ORDER)
  end

  def create
    begin
      @teacher = @admin.children.new_with_role_name(:teacher, params[:user])
      @teacher.school_id = @admin.school_id
      @teacher.skip_password!
      if @teacher.save
       message = I18n.t('admin.teacher.created_successfully', :name => @teacher.full_name)
       flash[:notice] = message
      end
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::TeachersController#create")
    end

  end

  def edit
    if @teacher.blank?
      render_page_not_found(I18n.t("admin.teacher.not_found"))
    end
  end
  
  def update
    if @teacher.blank?
      render_page_not_found(I18n.t("admin.teacher.not_found"))
      return
    end

    begin
      @teacher.skip_password!
      if @teacher.update_attributes(params[:user])
        message = I18n.t('admin.teacher.updated_successfully', :name => @teacher.full_name)
        flash[:notice] = message
      end
    rescue Exception => exc
      ::Util.log_error(exc, "Admin::TeachersController#update")
    end
  end 

  # GET: /admin/teacher/search?query=<QUERY>
  # TODO: optimize this method
  def search
    searcher = @admin || @user
    query = params[:query]
    if query.blank?
      redirect_to(:action => 'index', :admin_id => @admin.id)
    else
      query.strip!

      case params[:type]
        when 'student' then
          @students = Student.students_of_teacher(searcher).search_data(query, filtered_params)
        when 'teacher' then
          @teachers = searcher.children.unblocked.search_data(query, filtered_params)
        else
          @students = Student.students_of_teacher(searcher).search_data(query, filtered_params)
          @teachers = searcher.children.unblocked.search_data(query, filtered_params)
      end
    end
  end

  def get_students
    if @teacher.blank?
      render_page_not_found(I18n.t("admin.teacher.not_found"))
      return
    end
    
    @students = @teacher.accessible_students
    render :partial => 'admin/teachers/get_students'
  end

  protected

    def set_current_tab
      @current_tab = 'classroom'
    end

    # Find record and render page not found if the record does not exist.
    # If current_user is Super Admin
    #   Get user admin via user_id
    # else
    #   Get user admin via current_user
    # Get teacher from id
    #
    def find_user
      parse_params_to_get_users

      if !@admin
        render_page_not_found(I18n.t("user.error_not_found"))
        return false
      else
        teacher_id = params[:id] || params[:user_id]
        @teacher = @admin.children.unblocked.find_by_id(teacher_id)
      end

      return true
    end
end
