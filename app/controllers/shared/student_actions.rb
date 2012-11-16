# TODO: refactor Admin controllers
module Shared::StudentActions
  def new
    @student = Student.new
  end  
  
  def edit
    @student = Student.find(params[:id])
    @goals = @student.goals.order('is_completed ASC').load_data(filtered_params)
    session[:student_id] = params[:id]
    @invited_users = StudentSharing.where(:student_id => params[:id])

    if request.xhr?
      render :partial => "shared/students/view_goal", :locals => {:goals => @goals}
    end
  end

  def destroy
    @student = Student.find(params[:id])
    @student.destroy
    redirect_to students_url
  end
end
