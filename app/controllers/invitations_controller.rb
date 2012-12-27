class InvitationsController < ApplicationController 
  authorize_resource :student_sharing
  cross_role_action :new, :create, :edit, :update, :destroy
  before_filter :find_responder, :find_student

  def new 
    @sharing = @student.sharings.new    
  end 
  
  def create
    @sharing = @student.sharings.new params[:student_sharing]
    if @sharing.save 
      UserMailer.invited_confirmation(@sharing).deliver
    end 
  end 
  
  def edit 
    @sharing = @student.sharings.find_by_id params[:id]
  end 
  
  def update
    @sharing = @student.sharings.find_by_id params[:id]

    # To prevent hacking role
    existed_user = User.unblocked.find_by_email params[:student_sharing][:email]
    if existed_user 
      params[:student_sharing][:role_id] = existed_user.role.id
    end 

    @sharing.update_attributes params[:student_sharing]
  end
  
  def destroy
    sharing = @student.sharings.find_by_id params[:id]
    sharing.destroy
  end

  protected
    # Must have user_id which can be current user id or other is viewed as
    def find_responder
      @responder = User.find_by_id(params[:user_id])
      @responder ||= current_user
      @responder
    end

    def find_student
      parse_params_to_get_users

      if !@user
        render_page_not_found(I18n.t("user.error_not_found")) and return
        return false
      end
        
      @student = @user.accessible_students.find_by_id(params[:student_id])
      
      return true if @student
      
      render_page_not_found(I18n.t("student.student_not_found")) and return
    end
end 
