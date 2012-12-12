class CurriculumsController < ApplicationController
  authorize_resource :curriculum

	def index
	end
	
	protected

  def set_current_tab
    @current_tab = 'curriculum'
  end
end
