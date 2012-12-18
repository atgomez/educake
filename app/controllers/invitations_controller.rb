class InvitationsController < ApplicationController 
  authorize_resource :student_sharing
  cross_role_action :new, :create, :edit, :update, :destroy
  before_filter :find_responder

  def new 
    @user = StudentSharing.new    
  end 
  
  def create
    @user = StudentSharing.new params[:student_sharing]
    if @user.save 
      UserMailer.invited_confirmation(@user).deliver
    end 
  end 
  
  def edit 
    @user = StudentSharing.find params[:id]
  end 
  
  def update
    @user = StudentSharing.find params[:id]

    # To prevent hacking role
    existed_user = User.unblocked.find_by_email params[:student_sharing][:email]
    if existed_user 
      params[:student_sharing][:role_id] = existed_user.role.id
    end 

    if @user.update_attributes params[:student_sharing]
    end 
  end
  
  def destroy 
    user = StudentSharing.find params[:id]
    user.destroy
  end

  protected
    # Must have user_id which can be current user id or other is viewed as
    def find_responder
      @responder = User.find_by_id(params[:user_id])
      @responder ||= current_user
      @responder
    end
end 
