class SuperAdmin::SchoolsController < ApplicationController
  helper_method :sort_column, :sort_direction
  def index
    @schools = School.order(sort_column + ' ' + sort_direction).load_data(filtered_params)
  end

  def show
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @school }
    end
  end

  def new
    @school = School.new
    @school.users.build
  end

  def edit
    @school = School.find(params[:id])
  end

  def create
    @school = School.new(params[:school])

    if @school.save
      #UserMailer.admin_confirmation(@school.users.admins.first).deliver
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
      redirect_to @school
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
    School.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
end
