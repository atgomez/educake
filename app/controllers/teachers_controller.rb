class TeachersController < ApplicationController
  layout "common"

  def index
    @students = current_user.students.load_data(filtered_params)
  end

  protected

  def set_current_tab
    @current_tab = 'classroom'
  end
end
