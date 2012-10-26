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
    @goals = @student.goals.load_data(filtered_params)
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
  
  def search_user 
    user = StudentSharing.find_by_email(params[:email])
    if user 
      render :json => user.attributes.except("created_at, updated_at")
    else 
      render :json => {:existed => false}
    end
  end
  
  def common_chart
    @categories = []
    @chart_width = "100%"
    @series = []
    @student = Student.find params[:id]
    @goals = @student.goals.load_data(filtered_params)
    @goals.each do |goal| 
      data = []
      goal.statuses.is_ideal(true).each{|status| 
        data << [status.due_date, status.accuracy]
      }
      data << [goal.due_date, goal.accuracy]
      @series << {
                   :name => goal.name,
                   :data => data
                  }
    end

    @series = @series.to_json
    render :template => 'students/common_chart', :layout => "chart"
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
