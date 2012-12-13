class ProfileController < ApplicationController
  authorize_resource :user

  # GET /my_account
  def show
    @user = current_user
  end

  # POST /change_password
  def change_password
    result = {}
    status_code = 400
    @user = current_user

    begin
      if @user.change_password(params[:user])
        result[:status] = "ok"
        flash[:notice] = I18n.t("profile.change_password_success")      
        status_code = 200

        # Sign in the user by passing validation in case his password changed,
        # Otherwise, the user will be logged out.
        sign_in @user, :bypass => true
      elsif !@user.errors.blank?
        result[:status] = "error"
        result[:html] = render_to_string(:partial => "profile/password_form")
      else
        result[:status] = "error"
        result[:message] = I18n.t("profile.change_password_fail")
      end
    rescue Exception => exc
      ::Util.log_error(exc, "ProfileController#change_password")
      result[:status] = "error"
      result[:message] = I18n.t("profile.change_password_fail")
    end
    
    render(:json => result, :status => status_code)
  end

  protected

    def is_restricted?
      @is_restricted = false
    end
end
