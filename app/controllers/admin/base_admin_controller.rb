class Admin::BaseAdminController < ApplicationController
  before_filter :authenticate_admin!

  def index
    redirect_to '/admin/teachers'
  end

  protected

    # TODO: implement this method
    def authenticate_admin!
      authorize_action!(User, :manage)
    end

end
