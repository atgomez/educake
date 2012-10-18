class Admin::TeachersController < Admin::BaseAdminController
  layout "common"
  
  def index
    @teachers = current_user.children.all
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
    @sharing_students = Student.load_data(filtered_params, student_ids)
  end 
  protected

  def set_current_tab
    @current_tab = 'classroom'
  end
end
