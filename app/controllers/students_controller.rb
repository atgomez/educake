class StudentsController < ApplicationController
  layout "common"
  before_filter :destroy_session, :except => [:show, :destroy]
    
  def show
    @student = Student.find(params[:id])
    @teacher = @student.teacher 
    @students = Student.where("teacher_id = ?  and id !=?", @teacher.id, params[:id]).limit 4
    @goals = @student.goals.load_data(filtered_params)
    if request.xhr?
      @goals = @student.goals.load_data(filtered_params)
      render :partial => "view_goal", :locals => {:goals => @goals}
    end 
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
    goals = Goal.load_data(filtered_params).where(:student_id => params[:id])
    render :partial => "view_goal", :locals => {:goals => goals}
  end
  
  protected

  def set_current_tab
    @current_tab = 'classroom'
  end
  
  private
  def destroy_session  
    session.delete :tab
  end 
end
