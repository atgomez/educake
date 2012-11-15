class Admin::BaseAdminController < ApplicationController
  layout "admin"  
  before_filter :authenticate_admin!
  before_filter :do_filter_params
  before_filter :pagination_ajax_setting

  def index
    redirect_to '/admin/teachers'
  end

  protected

    # Use this for ajax pagination
    def pagination_ajax_setting
      @current_page = params[:page_id] ||= 1
      @is_page_increment = params[:page_id].to_i > params[:current_page].to_i
    end

    # TODO: implement this method
    def authenticate_admin!
      authorize_action!(User, :manage)
    end

    def do_filter_params
      # TODO: filter paging info and other necessary parameters.
      @filtered_params = params
      @filtered_params = @filtered_params.symbolize_keys
      # Check the page_size params.
      if @filtered_params[:page_size].to_i <= 0
        @filtered_params[:page_size] = default_page_size
      elsif @filtered_params[:page_size].to_i > MAX_PAGE_SIZE
        @filtered_params[:page_size] = MAX_PAGE_SIZE
      end
      
      return @filtered_params
    end

    def filtered_params
      @filtered_params
    end

end
