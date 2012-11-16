class Admin::StudentsController < Admin::BaseAdminController
  include ::Shared::StudentActions
  
  def show
    @teachers = []
    @student = Student.find(params[:id])
    @teacher = @student.teacher 
    @goals = @student.goals.incomplete.is_archived(false).load_data(filtered_params)
    @students = @teacher.accessible_students.limit 4
    #Check to hide placeholder for chart
    @data = []
    goals = @student.goals.incomplete.is_archived(false)
    goals.each do |goal| 
      goal.statuses.each{|status| 
        @data += [status.due_date, (status.accuracy*100).round / 100.0]
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
      @goals = @student.goals.load_data(filtered_params)      
      render :partial => "shared/students/view_goal", :locals => {:goals => @goals, :students => @students}
    end
    @invited_users = StudentSharing.where(:student_id => @student.id)
    session[:student_id] = params[:id]
  end
  
  def create
    @student = Student.new(params[:student])
    @student.teacher_id = session[:teacher_id]
    if @student.save
      redirect_to admin_student_path(@student), :notice => 'Student was successfully created.'
    else
      render :action => "new"
    end
  end
 
  def update
    @student = Student.find(params[:id])

    if @student.update_attributes(params[:student])
      redirect_to admin_student_path(@student), :notice => 'Student was successfully updated.'
    else
      render :action => "edit" 
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
