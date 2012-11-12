class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user!
  before_filter :do_filter_params
  before_filter :set_current_tab

  rescue_from CanCan::AccessDenied, :with => :render_unauthorized 

  PAGE_SIZE = 6
  MAX_PAGE_SIZE = 100

  protected

    # You can override this method in the sub class.
    def default_page_size
      PAGE_SIZE
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

    def set_current_tab
      "please override this method in your sub class"
      # @current_tab = "home"
    end

    # Override Cancan ability method
    def current_ability
      # Always refresh ability
      @current_ability = Ability.new(current_user)
    end
    
    def render_unauthorized
      respond_to do |format|
        format.html {
          render :file => "public/403.html", :status => 403, :layout => false
        }
        
        format.json {
          render :json => I18n.t("common.error_unauthorized"), :status => 403
        }
      end
    end

    # Authorize a specific action.
    #
    # === Parameters
    #
    #   * object: can be a Class or Object.
    #   * action (String/Symbol) (optional): name of the action. Default is the current action.
    # 
    def authorize_action!(object, action = nil)
      action ||= params[:action]
      unless action.blank?
        action = action.to_s.to_sym
      end
      authorize!(action, object)
    end
end
