class InvitationsController < ApplicationController 
  cross_role_action :new, :create, :edit, :update, :destroy

  def new 
    @user = StudentSharing.new    
  end 
  
  def create
    existed_user = User.unblocked.find_by_email params[:student_sharing][:email]
    if existed_user 
      params[:student_sharing][:role_id] = existed_user.role.id
    end 
    @user = StudentSharing.new params[:student_sharing]
    if @user.save 
      UserMailer.invited_confirmation(@user).deliver
      session[:tab] = "user"
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
      session[:tab] = "user"
    end 
  end
  
  def destroy 
    user = StudentSharing.find params[:id]
    user.destroy
    session[:tab] = "user"
  end
end 
