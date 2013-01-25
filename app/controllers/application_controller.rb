class ApplicationController < ActionController::Base
  include MongodbLogger::Base
  protect_from_forgery
  check_authorization :unless => :except_controller?

  before_filter :authenticate_user!
  before_filter :do_filter_params
  before_filter :set_current_tab
  before_filter :pagination_ajax_setting
  before_filter :check_blocked_account
  before_filter :check_view_as_state

  rescue_from CanCan::AccessDenied, :with => :rescue_access_denied 

  PAGE_SIZE = 8
  MAX_PAGE_SIZE = 100

  #
  # Class methods
  #
  class << self
    # # Contain list of crossed role actions that are internally used in the current class.
    # # TODO: this will not work for inherit classes. Consider using cattr_accessor ?
    # attr_accessor :_crossed_role_action

    # # Set value for crossed_role_action
    # # Please use list of Symbol instead of String, otherwise it won't work properly!
    # def cross_role_action(*actions)
    #   @_crossed_role_action = actions
    # end

    # def crossed_role_action
    #   @_crossed_role_action ||= []
    # end
  end
  
  def check_blocked_account
    user = current_user
    return if (user.blank? || self.is_devise_controller?)
    if user && user.is_blocked?
      render_error(I18n.t("common.error_blocked_account"), :status => 403)
    end
  end 

  def check_view_as_state
    if (current_user)
      @is_view_as = current_user.is_super_admin? && (params[:user_id] || params[:admin_id])
      if (@is_view_as)
        if (params[:admin_id])
          @viewing_user = User.find_by_id(params[:admin_id])
        else
          @viewing_user = User.find_by_id(params[:user_id])
        end
      end

      @is_view_as = false if !@viewing_user
    end
  end

  # To avoid DRY in all controllers.
  # 
  
  def parse_params_to_get_users
    @current_user = current_user
    @admin = User.unblocked.find_by_id params[:admin_id]
    if @current_user.is_super_admin?
      @admin = nil if @admin && !@admin.is?(:admin)
      @user = @admin ? @admin.children.unblocked.find_by_id(params[:user_id]) : 
                         User.unblocked.find_by_id(params[:user_id])
    elsif @current_user.is?(:admin) # If current user is admin, deny getting admin from admin_id
      @admin = @current_user
      @user = @admin.children.unblocked.find_by_id(params[:user_id])
    else
      @user = @current_user
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

    # # Return list of crossed role actions
    # def crossed_role_action
    #   self.class.crossed_role_action
    # end

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
      @current_ability ||= Ability.new(current_user)
    end
    
    def rescue_access_denied
      render_unauthorized
    end
    
    def render_unauthorized(options = {})
      options.merge!({:status => 403})
      render_error(I18n.t("common.error_unauthorized"), options)
    end

    def render_page_not_found(message = nil, options = {})
      message ||= I18n.t("common.error_page_not_found")
      options.merge!({:status => 404})
      render_error(message, options)
    end

    # Render error message. This method can handle HTML and JSON format.
    #
    # === Parameters
    #
    #   * message (String): the error message
    #   * options (Hash) (optional): extra options for Rails render() method, Ex :layout, :status, etc.
    #       There is one more options[:iframe] (boolean) so that we can call when rendering in an iframe.
    #       When the option :iframe is set as True, the default layout will be disabled.
    #       Ex: render("Error message", :iframe => true) 
    #
    def render_error(message, options = {})
      # Set default status code (if necessary)
      options = {:status => 400}.merge!(options)

      if options[:layout] == false
        @without_default_layout = true
      end

      if options.delete(:iframe)
        # Render error message from iframe
        @iframe = true
        # Disable the default layout      
        options[:layout] = false
      end

      respond_to do |format|
        format.html {
          flash.now[:alert] = message
          render("shared/error", options)
        }
        
        format.any(:json, :js) {
          options.merge!({:json => message})
          render(options)
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

    # def restrict_namespace
    #   if !is_rails_admin_controller?
    #     user = current_user
    #     return if (user.blank? || self.is_devise_controller? || !self.is_restricted?)
    #     action = self.action_name.to_sym
    #     if (user.is?(:admin) && !self.is_a?(Admin::BaseAdminController) && 
    #           !self.crossed_role_action.include?(action))
    #       redirect_to "/admin/teachers"
    #     elsif (user.is_super_admin? && !self.is_a?(SuperAdmin::BaseSuperAdminController) && 
    #           !self.crossed_role_action.include?(action))
    #       redirect_to '/super_admin/schools'
    #     end
    #   end
    # end


    def except_controller?
      except_controllers = [DeviseController, HomeController, 
                            GoalsController, RailsAdmin::MainController,
                            SubscribersController, ChartsController,
                            ExportController, StudentsController, InvitationsController,
                            OauthClientsController, OauthController]

      except_controllers.each do |class_controller|
        return true if self.is_a?(class_controller)
      end
      return false
    end

    def is_devise_controller?
      self.is_a?(DeviseController)
    end

    def is_restricted?
      @is_restricted = true
    end

    def exception_engine_authentication
      authenticate_admin!
    end
end
