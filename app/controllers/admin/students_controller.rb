class Admin::StudentsController < StudentsController
  layout "common"
  def show
    @student = Student.find(params[:id])
    @teacher = @student.teacher 
    @teachers = []
    @students = Student.where("teacher_id = ?  and id !=?", @teacher.id, params[:id]).limit 4
    session[:student_id] = params[:id]
    if params[:related]
      @teachers << @teacher 
      user_ids = StudentSharing.where(:student_id => params[:id]).map(&:user_id)
      @teachers += User.find user_ids
      #@teachers.sort { |a,b| a.full_name.downcase <=> b.full_name.downcase }
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
