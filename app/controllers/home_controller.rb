class HomeController < ApplicationController
  #authorize_resource :student
  skip_before_filter :authenticate_user!
  
  def index
  	if user_signed_in?
  		user = current_user
      if (user.is?(:admin))
          redirect_to "/admin/teachers"
      elsif (user.is_super_admin?)
          redirect_to '/super_admin/schools'
      else
  			redirect_to("/students")
  		end
  	else
  		redirect_to new_subscriber_path
  	end 
  end
end
