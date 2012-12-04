class StudentsController < ApplicationController
  include ::Shared::StudentActions
  before_filter :destroy_session, :except => [:show, :destroy]
  cross_role_action :common_chart, :chart, :search_user, 
                    :show, :create, :edit, :update

  def index
    redirect_to('/teachers')
  end

  def show
    @current_user = current_user
    @student = Student.find(params[:id])
    @teacher = @student.teacher 
    @goals = @student.goals.incomplete.load_data(filtered_params)
    @students = @teacher.accessible_students
    #Check to hide placeholder for chart
    @data = []
    @goals.each do |goal| 
      goal.grades.each{|grade| 
        @data += [grade.due_date, (grade.accuracy*100).round / 100.0]
      }
    end
    if @data.empty?
      @height = "0"
      @width = "0%"
    else
      @height = "500"
      @width = "100%"
    end 
    if request.xhr?
      render :partial => "shared/students/view_goal", :locals => {:goals => @goals, :students => @students}
    end
    @invited_users = StudentSharing.where(:student_id => @student.id)
    session[:student_id] = params[:id]
  end

  def create
    @student = Student.new(params[:student])
    @student.teacher = current_user
    @back_link = params[:back_link]
    
    if @student.save
      flash[:notice] = 'Student was successfully created.'
      redirect_to :action => 'edit', :id => @student
    else
      render :action => "new"
    end
  end
 
  def update
    @student = Student.find(params[:id])

    if @student.update_attributes(params[:student])
      redirect_to @student, :notice => 'Student was successfully updated.'
    else
      render :action => :edit
    end
  end 

  def load_users 
    users = StudentSharing.where(:student_id => params[:id])
    render :partial => "shared/students/view_invited_user", :locals => {:invited_users => users}
  end
  
  def search_user
    user = User.find_by_email(params[:email])
    existed_user = true
    unless user
      existed_user = false
      user = StudentSharing.find_by_email(params[:email]) 
    end
    
    if user 
      render :json => user.attributes.except("created_at, updated_at").merge(:disable => existed_user)
    else 
      render :json => {:existed => false}
    end
  end 

  protected

    def set_current_tab
      @current_tab = 'classroom'
    end

    def destroy_session  
      session.delete :tab
    end 
end
