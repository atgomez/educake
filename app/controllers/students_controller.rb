class StudentsController < ApplicationController
  layout "common"
  before_filter :destroy_session, :except => [:show, :destroy]
  
  def index
    redirect_to('/teachers')
  end

  def show
    @student = Student.find(params[:id])
    @teacher = @student.teacher 
    @goals = @student.goals.incomplete.is_archived(false).load_data(filtered_params)
    @students = @teacher.students
    if request.xhr?
      @goals = @student.goals.load_data(filtered_params)      
      render :partial => "view_goal", :locals => {:goals => @goals, :students => @students}
    end
    @invited_users = StudentSharing.where(:student_id => @student.id)
    session[:student_id] = params[:id]
  end

 
  def new
    @student = Student.new
  end
  
  
  def edit
    @student = Student.find(params[:id])
    @goals = @student.goals.order('is_completed ASC').load_data(filtered_params)
    session[:student_id] = params[:id]
    @invited_users = StudentSharing.where(:student_id => params[:id])

    if request.xhr?
      render :partial => "view_goal", :locals => {:goals => @goals}
    end
  end


  def create
    @student = Student.new(params[:student])

    if @student.save
      flash[:notice] = 'Student was successfully created.'
      redirect_to :action => 'edit', :id => @student
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
    @series = []
    @student = Student.find params[:id]
    @goals = @student.goals.incomplete.is_archived(false).load_data(filtered_params)
    @goals.each do |goal| 
      data = []
      goal.statuses.each{|status| 
        data << [status.due_date, (status.accuracy*100).round / 100.0]
      }
      #data << [goal.due_date, goal.accuracy]
      #Sort data by due date
      unless data.empty?
        data = data.sort_by { |hsh| hsh[0] } 
        @series << {
                     :name => goal.name,
                     :data => data
                    }
      end
    end
    @series = @series.to_json
    render :template => 'students/common_chart', :layout => "chart"
  end
  
  def chart 
    @goal = Goal.find params[:goal_id]
    @series = []
    data = []

    data << [@goal.baseline_date, (@goal.baseline.round*100).round  / 100.0]
    # For ideal data
    @goal.progresses.each{|progress| 
      data << [progress.due_date, (progress.accuracy*100).round / 100.0]
    }
    data << [@goal.due_date, (@goal.accuracy*100).round  / 100.0]
    #Sort data by due date
    data = data.sort_by { |hsh| hsh[0] }
    
    @series << {
                 :type => 'line',
                 :name => "Ideal chart",
                 :data => data
                }
    # For add status 
    data = []
    @goal.statuses.each{|status| 
      data << [status.due_date, (status.accuracy*100).round / 100.0]
    }
    data = data.sort_by { |hsh| hsh[0] }
    @series << {
                 :name => @goal.name,
                 :data => data
                }
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
