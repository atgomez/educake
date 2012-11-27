class SuperAdmin::SchoolsController < SuperAdmin::BaseSuperAdminController
  helper_method :sort_column, :sort_direction
  def index
      @schools = School.joins(:users).order(sort_column + ' ' + sort_direction).load_data(filtered_params)
  end

  def show
    @school = School.find(params[:id])
    session[:school] = @school.id
    @users = @school.users.load_data(filtered_params)
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
    @school = School.new(params[:school])
   
    if @school.save
      UserMailer.admin_confirmation(@school.users.admins.first).deliver
      flash[:notice] = 'School was successfully created.' 
      redirect_to super_admin_schools_path
    else
      render action: "new" 
    end
  end

  def update
    @school = School.find(params[:id])

    if @school.update_attributes(params[:school])
      flash[:notice] = 'School was successfully updated.'
      redirect_to super_admin_schools_path
    else
      render action: "edit" 
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
end
