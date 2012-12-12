class HomeController < ApplicationController
  authorize_resource :student

  def index
  	redirect_to("/students")
  end
end
