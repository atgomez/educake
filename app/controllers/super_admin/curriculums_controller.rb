class SuperAdmin::CurriculumsController < SuperAdmin::BaseSuperAdminController
	def index
    @curriculums = Curriculum.load_data(filtered_params)
	end

  def edit
    find_curriculum
  end

  def update

  end

  def destroy
    if find_curriculum
      begin
        if @curriculum.destroy
          flash[:notice] = I18n.t("curriculum.deleted_successfully", :name => @curriculum.name)
        else
          flash[:alert] = I18n.t("curriculum.delete_failed", :name => @curriculum.name)
        end
      rescue ActiveRecord::DeleteRestrictionError
        flash[:alert] = I18n.t("curriculum.error_delete_in_used", :name => @curriculum.name)
      rescue Exception => exc
        ::Util.log_error(exc, "SuperAdmin::CurriculumsController#destroy")
        flash[:alert] = I18n.t("curriculum.delete_failed_without_name")
      end

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
      end
    end
  end
	
	protected

    def set_current_tab
      @current_tab = 'curriculum'
    end

    def find_curriculum
      @curriculum = Curriculum.find_by_id(params[:id])
      render_page_not_found(I18n.t("curriculum.not_found")) if !@curriculum
      return @curriculum
    end
end
