class StudentsController < ApplicationController
  include ::Shared::StudentActions
  before_filter :destroy_session, :except => [:show, :destroy]
  cross_role_action :search_user, :show, :create, :edit, :update

  def index
    if find_user
      @students = @user.accessible_students.load_data(filtered_params)
      series = []
      students = @user.accessible_students
      students.map do |student|
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
      @current_user = current_user
      @student = @user.accessible_students.find(params[:id])
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
    end
  end

  def create
    if find_user
      @student = @user.accessible_students.new(params[:student])
      @student.teacher = current_user
      @back_link = params[:back_link]
      
      if @student.save
        flash[:notice] = 'Student was successfully created.'
        redirect_to :action => 'edit', :id => @student
      else
        render :action => "new"
      end
    end
  end
 
  def update
    if find_user
      @student = @user.accessible_students.find(params[:id])

      if @student.update_attributes(params[:student])
        redirect_to @student, :notice => 'Student was successfully updated.'
      else
        render :action => :edit
      end
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

  def all_students
    @students = current_user.accessible_students
  end

  protected

    def find_user
      @current_user = current_user
      if (params[:user_id])
        @user = User.find_by_id params[:user_id]
      else
        @user = @current_user
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
