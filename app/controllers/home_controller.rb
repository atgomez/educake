class HomeController < ApplicationController
  #authorize_resource :student
  skip_before_filter :authenticate_user!
  
  def index
    if user_signed_in?
      user = current_user
      if is_mobile_request?
        # Mobile view
        # TODO: change this code
        if user.is?(:teacher)
          redirect_to("/goals/new_grade")
        end
      else
        if (user.is?(:admin))
          redirect_to "/admin/teachers"
        elsif (user.is_super_admin?)
          redirect_to '/super_admin/schools'
        else
          redirect_to("/students")
        end
      end
    else
      if is_mobile_request?
        # TODO: workaround to fix the problem of Devise authenticate method,
        # that cannot correctly redirect to the mobile view.
        redirect_to(new_user_session_path)
      else
        redirect_to new_subscriber_path
      end
    end 
  end
end
