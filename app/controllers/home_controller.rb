class HomeController < ApplicationController
  #authorize_resource :student
  skip_before_filter :authenticate_user!
  
  def index
  	if user_signed_in?
  		redirect_to("/students")
  	else
  		redirect_to new_subscriber_path
  	end 
  end
end
