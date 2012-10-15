class Admin::TeachersController < Admin::BaseAdminController
  def index
    @teachers = current_user.children.all
  end

  # TODO: implement this method.
  def create

  end
end
