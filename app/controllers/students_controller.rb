class StudentsController < ApplicationController

  before_filter :destroy_session, :except => [:show, :destroy]
  cross_role_action :new, :search_user, :index, :destroy, :show, :create, :edit, :update, :all_students, :load_users, :search_user

  def index
    if find_user
      @students = @user.accessible_students.load_data(filtered_params)
      series = []
      @all_students = @user.accessible_students
      @all_students.map do |student|
        series += student.goals_grades
      end
      if series.empty?
        @width = "0%"
        @height = "0"
      else 
        @width = "100%"
        @height = "500"
      end 

      respond_to do |format|
        format.js
        format.html
      end
    end
  end

  def show
    if find_user
      @student = @user.accessible_students.find_by_id(params[:id])
      @all_students = @user.accessible_students
      if @student
        @goals = @student.goals.incomplete.load_data(filtered_params)
        @students = @user.accessible_students
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
      else
        render_page_not_found
      end
    end
  end

  def new
    if find_user
      @student = Student.new
      @back_link = params[:back_link]
    end
  end  
  
  def edit
    if find_user
      @student = @user.accessible_students.find(params[:id])
      if @student
        @goals = @student.goals.order('is_completed ASC').load_data(filtered_params)
        session[:student_id] = params[:id]
        @invited_users = StudentSharing.where(:student_id => params[:id])

        if request.xhr?
          render :partial => "shared/students/view_goal", :locals => {:goals => @goals, :student => @student}
        end
      else
        render_page_not_found
      end
    end
  end

  def create
    if find_user
      @student = @user.accessible_students.new(params[:student])
      @student.teacher = @user
      @back_link = params[:back_link]
      
      if @student.save
        flash[:notice] = 'Student was successfully created.'
        redirect_to :action => 'edit', :id => @student, :user_id => @user
      else
        render :action => "new"
      end
    end
  end

  def update
    if find_user
      @student = @user.accessible_students.find(params[:id])
      if @student
        if @student.update_attributes(params[:student])
          redirect_to student_path(@student, :user_id => @user.id), :notice => 'Student was successfully updated.'
        else
          render :action => :edit
        end
      else
        render_page_not_found
      end
    end
  end 
  
  def destroy
    if find_user
      @student = @user.accessible_students.find(params[:id])
      @student.destroy
      redirect_to students_url
    end
  end

  def load_grade
    goals = Goal.load_data(filtered_params).where(:student_id => params[:id])
    @goals_grades = {}
    goals.each do |goal|
      @goals_grades[goal.id] = goal.grades.order('due_date ASC').load_data(filtered_params)
    end 
    render :partial => "shared/students/view_goal", :locals => {:goals => goals, :grades => @goals_grades}
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

  def all_students
    if find_user
      @students = @user.accessible_students
      @series = []
      @students.map do |student|
        @series += student.goals_grades
      end
    end
  end

  protected

    def find_user
      @current_user = current_user
      if (params[:user_id])
        @user = User.unblocked.find_by_id params[:user_id]
      else
        @user = current_user
      end
      if !@user
        render_page_not_found
        return false
      end
      if !(can? :view, @user)
        render_unauthorized
        return false
      end
      return true
    end

    def set_current_tab
      @current_tab = 'classroom'
    end

    def destroy_session  
      session.delete :tab
    end 

    protected

    # You can override this method in the sub class.
    def default_page_size
      8
    end
end
