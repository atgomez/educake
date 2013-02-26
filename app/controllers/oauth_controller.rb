require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  alias :login_required :authenticate_user!
  include OAuth::Controllers::ProviderController
  skip_before_filter :set_request_format, :detect_mobile_device
  skip_before_filter :login_required, :authenticate_user!, :only => [:token]


  protected
  # Override this to match your authorization page form
  # It currently expects a checkbox called authorize
  # def user_authorizes_token?
  #   params[:authorize] == '1'
  # end

  # should authenticate and return a user if valid password.
  # This example should work with most Authlogic or Devise. Uncomment it
  # def authenticate_user(username,password)
  #   user = User.find_by_email params[:username]
  #   if user && user.valid_password?(params[:password])
  #     user
  #   else
  #     nil
  #   end
  # end

end
