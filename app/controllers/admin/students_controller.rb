class Admin::StudentsController < StudentsController
  def show
    @teachers = []
    @student = Student.find(params[:id])
    @teacher = @student.teacher 
    @goals = @student.goals.incomplete.is_archived(false).load_data(filtered_params)
    @students = @teacher.students.limit 4
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
      render :partial => "view_goal", :locals => {:goals => @goals, :students => @students}
    end
    if params[:related]
      @teachers << @teacher 
      user_ids = StudentSharing.where(:student_id => params[:id]).map(&:user_id)
      @teachers += User.find(user_ids)
      #@teachers.sort { |a,b| a.full_name.downcase <=> b.full_name.downcase }
    end
    @invited_users = StudentSharing.where(:student_id => @student.id)
  end
  
  def create
    @student = Student.new(params[:student])

    if @student.save
      redirect_to admin_student_path(@student), notice: 'Student was successfully created.'
    else
      render action: "new"
    end
  end
 
  def update
    @student = Student.find(params[:id])

    if @student.update_attributes(params[:student])
      redirect_to admin_student_path(@student), notice: 'Student was successfully updated.'
    else
      render action: "edit" 
    end
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
