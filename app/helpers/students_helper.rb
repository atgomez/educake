module StudentsHelper
  def current_student_admin
    return @admin if @admin
    # Try to query from the student
    @student.teacher.school.admin
  end
end
