class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user!
  before_filter :do_filter_params
  before_filter :set_current_tab
  before_filter :restrict_namespace
  before_filter :pagination_ajax_setting

  rescue_from CanCan::AccessDenied, :with => :render_unauthorized 

  PAGE_SIZE = 8
  MAX_PAGE_SIZE = 100

  #
  # Class methods
  #
  class << self
    # Contain list of crossed role actions that are internally used in the current class.
    # TODO: this will not work for inherit classes. Consider using cattr_accessor ?
    attr_accessor :_crossed_role_action

    # Set value for crossed_role_action
    # Please use list of Symbol instead of String, otherwise it won't work properly!
    def cross_role_action(*actions)
      @_crossed_role_action = actions
    end

    def crossed_role_action
      @_crossed_role_action ||= []
    end
  end

  #
  # Protected instance methods.
  #
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

    # Return list of crossed role actions
    def crossed_role_action
      self.class.crossed_role_action
    end

    def set_current_tab
      "please override this method in your sub class"
      # @current_tab = "home"
    end

    # Use this for ajax pagination
    def pagination_ajax_setting
      @current_page = params[:page_id] ||= 1
      @is_page_increment = params[:page_id].to_i > params[:current_page].to_i
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

    # This filter is to constraint the controller current user can access to.
    # It's because of the requirement: each role has a specific workspace, for ex:
    #   Admin only work in admin space, cannot go to teacher space.
    #
    def restrict_namespace
      user = current_user
      return if (user.blank? || self.is_devise_controller?)
      action = self.action_name.to_sym
      if (user.is?(:admin) && self.class.name.split("::").first != "Admin" && 
            !self.crossed_role_action.include?(action))
        redirect_to "/admin/teachers"
      end
    end

    def is_devise_controller?
      self.is_a?(DeviseController)
    end
end
