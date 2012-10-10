class HomeController < ApplicationController
  layout "common"

  # TODO: change the redirect link.
  def index
    redirect_to("/teachers")
  end
end
