class SuperAdmin::UsersController < SuperAdmin::BaseSuperAdminController 
  def new 
    @user = User.new
    @user.build_school
    @school_id = params[:school_id]
    @back = params[:back]
    load_roles
  end
  
  def create
    @user = User.new(params[:user])
    @school_id = params[:school_id]
    @back = params[:back]
    @school = School.find_by_id(@user.school_id)

    if (@school)
      @user.skip_password!
      @user.parent = @school.admin
      @user.school = @school

      if @user.save
        message = I18n.t('user.created_successfully', :name => @user.full_name)
        flash[:notice] = message
        redirect_to super_admin_school_path(@user.school)
      else
        load_roles
        render action: "new" 
      end
    else
      flash[:alert] = I18n.t('school.not_available')
      load_roles
      render action: "new" 
    end
  end
  
  def edit
    load_roles
    @user = User.find params[:id]
    @school_id = params[:school_id]
    @back = params[:back]
  end
  
  def update 
    @user = User.find params[:id]
    @school_id = params[:school_id]
    @back = params[:back]

    if @user.update_attributes params[:user]
      message = I18n.t('user.updated_successfully', :name => @user.full_name)
      flash[:notice] =  message
      redirect_to super_admin_school_path(@user.school)
    else
      load_roles
      render action: "edit" 
    end
  end
  
  def blocked_account 
    @user = User.find params[:id]
    if @user.update_attribute(:is_blocked, params[:is_blocked])
      UserMailer.inform_blocked_account(@user).deliver
    end 
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
      redirect_to students_path(:user_id => params[:id])
    end 
  end
  
  def search_result
    unless params[:school].blank?
      case params[:search_type].to_i
        when User::SCHOOL
          @users = User.joins(:role).joins(:school).where("lower(schools.name) like ? and schools.id = ?", "%#{params[:query].downcase}%", params[:school]).load_data(filtered_params)
        when User::ROLE
          @users = User.joins(:role).joins(:school).where("lower(roles.name) like? and schools.id = ?", "%#{params[:query].downcase}%", params[:school]).load_data(filtered_params)
        else  
          @users = User.joins(:school).where("schools.id = ?", params[:school]).like_search(params[:query], filtered_params)
      end
    else
      case params[:search_type].to_i
        when User::SCHOOL
          @users = User.joins(:role).joins(:school).where("lower(schools.name) like ? and role_id IS NOT NULL", "%#{params[:query].downcase}%").load_data(filtered_params)
        when User::ROLE
          @users = User.joins(:role).joins(:school).where("lower(roles.name) like? and role_id IS NOT NULL", "%#{params[:query].downcase}%").load_data(filtered_params)
        else  
          @users = User.like_search(params[:query], filtered_params)
      end
    end
  end

  protected

    def load_roles
      @roles = [Role[:teacher]]
    end
end
