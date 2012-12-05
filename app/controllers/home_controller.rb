class HomeController < ApplicationController
  def index
  	redirect_to("/students")
  end
end
