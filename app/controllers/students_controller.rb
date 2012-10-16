class StudentsController < ApplicationController
  layout "common"
  before_filter :destroy_session, :except => [:show, :destroy]
  
  def index
    @students = Student.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @students }
    end
  end

  def show
    @student = Student.find(params[:id])
    @students = Student.where("teacher_id = ?  and id !=?", current_user.id, params[:id]).limit 4
    session[:student_id] = params[:id]
  end

 
  def new
    @student = Student.new
  end
  
  
  def edit
    @student = Student.find(params[:id])
    session[:student_id] = params[:id]
    @invited_users = StudentSharing.where(:student_id => params[:id])
  end


  def create
    @student = Student.new(params[:student])

    if @student.save
      redirect_to @student, notice: 'Student was successfully created.'
    else
      render action: "new"
    end
  end

 
  def update
    @student = Student.find(params[:id])

    if @student.update_attributes(params[:student])
      redirect_to @student, notice: 'Student was successfully updated.'
    else
      render action: "edit" 
    end
  end

  def destroy
    @student = Student.find(params[:id])
    @student.destroy
    redirect_to students_url
  end
  
  def load_users 
    users = StudentSharing.where(:student_id => params[:id])
    render :partial => "view_invited_user", :locals => {:invited_users => users}
  end
  
  def load_status
    goals = Goal.where(:student_id => params[:id])
    render :partial => "view_goal", :locals => {:goals => goals}
  end
  
  private
  def destroy_session  
    session.delete :tab
  end 
end
