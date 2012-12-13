class SuperAdmin::BaseSuperAdminController < ApplicationController  
  before_filter :authenticate_admin!
  skip_authorization_check
  
  def index
    redirect_to '/super_admin/schools'
  end

  protected

    def authenticate_admin!
      authorize_action!(:all, :manage)
    end
end
