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
      flash[:notice] = 'User was created successfully.' 
      redirect_to super_admin_school_path(@user.school)
    else
      render action: "new" 
    end
  end
  
  def edit
    @user = User.find params[:id]
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
    if @user.update_attributes(:password => rand_pass, 
                               :password_confirmation => rand_pass, 
                               :temp_pass => rand_pass)
      UserMailer.send_reset_password(@user).deliver
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
    elsif user.is?(:teacher)
      redirect_to admin_teacher_path(user)
    end 
  end 
end
