class SuperAdmin::BaseSuperAdminController < ApplicationController
  layout "admin"  
  before_filter :authenticate_admin!

  def index
    redirect_to '/super_admin/schools'
  end

  protected

    def authenticate_admin!
      can?(:manage, :all)
    end

end
