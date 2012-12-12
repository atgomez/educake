class SuperAdmin::BaseSuperAdminController < ApplicationController  
  before_filter :authenticate_admin!

  def index
    redirect_to '/super_admin/schools'
  end

  protected

    def authenticate_admin!
      can?(:manage, :all)
    end

    def render_page_not_found(options = {})
      options.merge!({:status => 404})
      render_error(I18n.t("common.error_page_not_found"), options)
    end

end
