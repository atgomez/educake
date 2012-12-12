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
    
    begin
      if current_user.change_password(params[:user])
        result[:message] = I18n.t("profile.change_password_success")
        status_code = 200
      elsif !current_user.errors.blank?
        @user = current_user
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
