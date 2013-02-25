class SuperAdmin::UsersController < SuperAdmin::BaseSuperAdminController 
  def new 
    @school_id = params[:school_id]
    @back = params[:back]
    @user = User.new
    @user.build_school
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
        render(:action => "new")
      end
    else
      flash[:alert] = I18n.t('school.not_available')
      load_roles
      render(:action => "edit")
    end
  end
  
  def edit
    if find_user
      load_roles
      @school_id = params[:school_id]
      @school = School.find_by_id(@school_id)
      @back = params[:back]
    end
  end
  
  def update 
    if find_user
      @school_id = params[:school_id]
      @back = params[:back]
      @school = School.find_by_id(@school_id)
      
      if @user.is?(:admin)
        # Reject school_id when updating an admin
        params[:user].delete(:school_id)
      end
      if @user.update_attributes params[:user]
        message = I18n.t('user.updated_successfully', :name => @user.full_name)
        flash[:notice] =  message
        redirect_to super_admin_school_path(@user.school)
      else
        load_roles
        render(:action => "edit") 
      end
    end
  end
  
  def blocked_account 
    if find_user
      if @user.update_attribute(:is_blocked, params[:is_blocked])
        StudentSharing.where(:email => @user.email).update_all(:is_blocked => params[:is_blocked])
        UserMailer.inform_blocked_account(@user).deliver
      end 
    end
  end
  
  def reset_password 
    if find_user
      rand_pass = rand(897564)
      @success = false
      @user.password = rand_pass
      if @user.save
        UserMailer.send_reset_password(@user, rand_pass).deliver
        @success = true
      end
    end
  end
  
  def destroy
    if find_user
      school = @user.school
      @user.destroy
      
      redirect_to super_admin_school_path(school)
    end
  end
  
  def view_as
    if find_user
      if @user.is?(:admin)
        path = admin_teachers_path(:admin_id => params[:id]) 
      else
        path = students_path(:user_id => params[:id])
      end

      redirect_to path
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
      if params[:action] == "edit" || params[:action] == "update"
        @roles = [Role[:teacher], Role[:parent]]
      else
        @roles = [Role[:teacher]]
      end
    end

    def find_user
      @user = User.find_by_id(params[:id])
      render_page_not_found if !@user
      return @user
    end
end
