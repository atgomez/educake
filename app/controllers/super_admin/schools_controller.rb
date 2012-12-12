class SuperAdmin::SchoolsController < SuperAdmin::BaseSuperAdminController
  helper_method :sort_column, :sort_direction, :sort_criteria
  
  def index
    load_params = filtered_params.merge({
      :sort_criteria => sort_criteria
    })

    @schools = School.load_data_with_admin(load_params)
  end

  def show
    if find_school
      @users = @school.users.order('role_id').load_data(filtered_params)
      if params[:query]
        redirect_to search_result_super_admin_users_path(:school => @school.id, :query => params[:query])
      end
    end
  end

  def new
    @school = School.new
    @admin = @school.users.build
  end

  def edit
    if find_school
      @admin = @school.admin
    end
  end

  def create
    # Create the admin for the school.
    admin = User.new(params[:school].delete(:admin_attributes))
    admin.skip_password!
    @school = School.new(params[:school])
    @school.admin = admin

    # Save the school and admin
    if @school.save
      message = I18n.t('school.created_successfully', :name => @school.name)
      flash[:notice] = message

      redirect_to super_admin_school_path @school
    else
      render(:action => "new")
    end
  end

  def update
    if find_school
      if @school.update_attributes(params[:school])
        message = I18n.t('school.updated_successfully', :name => @school.name)
        flash[:notice] = message
        redirect_to super_admin_school_path @school
      else
        render(:action => "edit")
      end
    end
  end

  def destroy
    if find_school
      @school.destroy

      respond_to do |format|
        format.html { redirect_to schools_url }
        format.json { head :no_content }
      end
    end
  end
  
  private
  
    def sort_column
      School.column_names.include?(params[:sort]) || User.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end

    def find_school
      @school = School.find(params[:id])
      render_page_not_found if !@school
      return @school
    end

    def sort_criteria
      columns = sort_column
      direction = sort_direction
      if columns == 'last_name'
        return "first_name #{direction}, last_name #{direction}"
      else
        return "#{columns} #{direction}"
      end
    end
end
