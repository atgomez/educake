class SuperAdmin::UsersController < SuperAdmin::BaseSuperAdminController 
  def new 
    @user = User.new
    @user.build_school
    @roles = Role.where("name =? or name = ?", "Teacher", "Parent").order(:name).all
  end
  def create
    @user = User.new(params[:user])
    
    if @user.save
      UserMailer.admin_confirmation(@user).deliver
      flash[:notice] = 'User was successfully created.' 
      redirect_to super_admin_schools_path
    else
      render action: "new" 
    end
  end
end
