class TeachersController < ApplicationController
  layout "common"

  def index
    @students = current_user.students.load_data(filtered_params)
    student_ids = StudentSharing.where(:user_id => current_user.id).map(&:student_id)
    if student_ids.empty?
      @sharing_students = []
    else
      @sharing_students = Student.load_data(filtered_params, student_ids)
    end
  end

  protected

  def set_current_tab
    @current_tab = 'classroom'
  end
end
