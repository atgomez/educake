class SuperAdmin::SchoolsController < SuperAdmin::BaseSuperAdminController
  helper_method :sort_column, :sort_direction, :sort_criteria
  def index
    load_params = filtered_params.merge({
      :sort_criteria => sort_criteria
    })

    @schools = School.load_data_with_admin(load_params)
  end

  def show
    @school = School.find(params[:id])
    session[:school] = @school.id
    @users = @school.users.load_data(filtered_params)
    if params[:query]
      redirect_to search_result_super_admin_users_path+"?school="+ @school.id.to_s
    end
  end

  def new
    @school = School.new
    @admin = @school.users.build
  end

  def edit
    @school = School.find(params[:id])
    @admin = @school.users.admins.first
  end

  def create
    rand_pass = rand(1234567)
    params[:school][:users_attributes]['0'][:password] = rand_pass
    @school = School.new(params[:school])
    
    if @school.save
      UserMailer.admin_confirmation(@school.users.admins.first, rand_pass).deliver
      flash[:notice] = 'School was successfully created.' 
      redirect_to super_admin_schools_path
    else
      render(:action => "new")
    end
  end

  def update
    @school = School.find(params[:id])

    if @school.update_attributes(params[:school])
      flash[:notice] = 'School was successfully updated.'
      redirect_to super_admin_schools_path
    else
      render(:action => "edit")
    end
  end

  def destroy
    @school = School.find(params[:id])
    @school.destroy

    respond_to do |format|
      format.html { redirect_to schools_url }
      format.json { head :no_content }
    end
  end
  
  private
  
    def sort_column
      School.column_names.include?(params[:sort]) || User.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
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
