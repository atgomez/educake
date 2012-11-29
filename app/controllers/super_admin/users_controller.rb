class SuperAdmin::UsersController < SuperAdmin::BaseSuperAdminController 
  def new 
    @user = User.new
    @user.build_school
    session[:back] = params[:back]
    @roles = Role.where("name =? or name = ?", "Teacher", "Parent").order(:name).all
  end
  
  def create
    rand_pass = rand(1234567)
    params[:user][:password] = rand_pass
    @user = User.new(params[:user])
    
    if @user.save
      UserMailer.admin_confirmation(@user, rand_pass).deliver
      flash[:notice] = 'User was created successfully.' 
      redirect_to super_admin_school_path(@user.school)
    else
      render action: "new" 
    end
  end
  
  def edit
    @user = User.find params[:id]
    @roles = Role.where("name =? or name = ?", "Teacher", "Parent").order(:name).all
  end
  
  def update 
    @user = User.find params[:id]
    
    if @user.update_attributes params[:user]
      flash[:notice] = 'User was updated successfully.' 
      redirect_to edit_super_admin_user_path(@user)
    else
      render action: "edit" 
    end
  end
  
  def blocked_account 
    @user = User.find params[:id]
    @user.update_attribute(:is_locked, params[:is_locked])
  end
  
  def reset_password 
    @user = User.find params[:id]
    rand_pass = rand(897564)
    @success = false
    @user.password = rand_pass
    if @user.save
      UserMailer.send_reset_password(@user, rand_pass).deliver
      @success = true
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    school = @user.school
    @user.destroy
    
    redirect_to super_admin_school_path(school)
  end
  
  def view_as
    user = User.find params[:id]
    if user.is?(:admin)
      redirect_to admin_teachers_path(:user_id => params[:id]) 
    elsif user.is?(:teacher) || user.is?(:parent)
      redirect_to admin_teacher_path(user)
    end 
  end
  
  def search_result
    case params[:search_type].to_i
    when User::SCHOOL
      @users = User.joins(:role).joins(:school).where("lower(schools.name) like ?", "%#{params[:query].downcase}%").load_data(filtered_params)
    when User::ROLE
      @users = User.joins(:role).joins(:school).where("lower(roles.name) like?", "%#{params[:query].downcase}%").load_data(filtered_params)
    else  
      @users = User.like_search(params[:query], filtered_params)
    end
  end
end
