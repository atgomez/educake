class StudentsController < ApplicationController
  authorize_resource :student
  before_filter :except => [:show, :destroy]
  cross_role_action :new, :search_user, :index, :destroy, :show, :create, :edit, 
                    :update, :all_students, :load_users, :search_user

  def index
    if find_user
      @students = @user.accessible_students.load_data(filtered_params)
      series = []
      @all_students = @user.accessible_students
      @all_students.each do |student|
        series += student.goals_progress
        # Exit the loop, because we only need to detect there is data for chart or not.
        break unless series.blank?
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
        sponsors = @student.sponsors
        @invited_users = StudentSharing.unblocked.where("student_id = ? and email NOT IN (?)", @student.id, sponsors.map(&:email))
        @invited_users += sponsors 
        @invited_users.delete @user 
        sharing = StudentSharing.find_by_email(@user.email)
        @invited_users.delete sharing
        @invited_users = @invited_users.uniq
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
        sponsors = @student.sponsors
        @invited_users = StudentSharing.unblocked.where("student_id = ? and email NOT IN (?)", @student.id, sponsors.map(&:email))
        @invited_users += sponsors 
        sharing = StudentSharing.find_by_email(@user.email)
        @invited_users.delete sharing
        @invited_users = @invited_users.uniq

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
        message = I18n.t('student.created_successfully', :name => @student.full_name)
        flash[:notice] = message
        redirect_to :action => 'edit', :id => @student, :user_id => @user, :admin_id => @admin
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
          message = I18n.t('student.updated_successfully', :name => @student.full_name)
          redirect_to student_path(@student, :user_id => @user.id, :admin_id => @admin), :notice => message
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
    user = User.unblocked.find_by_email(params[:email])
    existed_user = true
    unless user
      existed_user = false
      user = StudentSharing.find_by_email(params[:email]) 
    end
    
    if user 
      render :json => user.to_hash.merge(:disable => existed_user)
    else 
      render :json => {:disable => false}
    end
  end 

  def all_students
    if find_user
      @students = @user.accessible_students
    end
  end

  protected

    def find_user
      @current_user = current_user
      @admin = User.unblocked.find_by_id params[:admin_id]
      @admin = nil if @admin && !@admin.is?(:admin)
      if (params[:user_id])
        @user = @admin ? @admin.children.teachers.find_by_id(params[:user_id]) : 
                         User.unblocked.find_by_id(params[:user_id])
      else
        @user = current_user if !current_user.is?(:admin) && !current_user.is_super_admin?
      end
      if !@user
        if @is_view_as
          render_page_not_found(I18n.t("user.error_not_found"))
        else
          render_page_not_found
        end
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

    # You can override this method in the sub class.
    def default_page_size
      8
    end
end
