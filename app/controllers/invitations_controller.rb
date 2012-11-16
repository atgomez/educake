class InvitationsController < ApplicationController 
  cross_role_action :new, :create, :update, :destroy

  def new 
    @user = StudentSharing.new 
  end 
  
  def create 
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
