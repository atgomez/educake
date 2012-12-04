# This customized class is to support user set their own password after registration.
# See: https://github.com/plataformatec/devise/wiki/How-To:-Override-confirmations-so-users-can-pick-their-own-passwords-as-part-of-confirmation-activation
class Devise::UserRegistrationsController < Devise::RegistrationsController
  # GET /resource/sign_up
  # Override Devise signing up, in order to not allow user can register new account.
  # Only being invited by other accounts.
  def new
    if params[:user_token].blank?
      redirect_to "/"
    else
      @sharing = StudentSharing.find_by_confirm_token(params[:user_token])
      if @sharing && !@sharing.confirmed?
        resource = build_resource({})
        self.resource.first_name = @sharing.first_name
        self.resource.last_name  = @sharing.last_name
        respond_with resource
      else
        redirect_to "/"
      end
    end
  end

  # POST /resource
  def create
    if params[:user_token].blank?
      redirect_to "/"
    else
      @sharing = StudentSharing.find_by_confirm_token(params[:user_token])
      if @sharing && !@sharing.confirmed?
        build_resource      
        # To prevent hacking
        self.resource.email      = @sharing.email
        self.resource.first_name = @sharing.first_name
        self.resource.last_name  = @sharing.last_name
        self.resource.role_id    = @sharing.role_id
        self.resource.school_id  = @sharing.student.teacher.school_id
        
        # Skip confirmation.
        self.resource.skip_confirmation! if self.resource.respond_to?(:skip_confirmation!)

        if resource.save
          if resource.active_for_authentication?
            set_flash_message :notice, :signed_up if is_navigational_format?
            # sign_in(resource, :bypass => true)
            sign_in(resource_name, resource)
            respond_with resource, :location => after_sign_up_path_for(resource)
          else
            set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
            expire_session_data_after_sign_in!
            respond_with resource, :location => after_inactive_sign_up_path_for(resource)
          end
        else
          clean_up_passwords resource
          respond_with resource
        end
      else
        redirect_to "/"
      end
    end
  end
end
