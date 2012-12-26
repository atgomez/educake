class SuperAdmin::CurriculumsController < SuperAdmin::BaseSuperAdminController
  helper_method :sort_column, :sort_direction, :sort_criteria

	def index
    load_params = filtered_params.merge({
      :sort_criteria => sort_criteria
    })
    @curriculums = Curriculum.load_data(load_params)
	end

  def edit
    find_curriculum
  end

  def update
    if find_curriculum
      begin
        if @curriculum.update_attributes(params[:curriculum])
          flash[:notice] = I18n.t("curriculum.updated_successfully", :name => @curriculum.name)
          redirect_to :action => 'index'
        else
          render(:action => 'edit')
        end
      rescue Exception => exc
        ::Util.log_error(exc, "SuperAdmin::CurriculumsController#update")
        flash.now[:alert] = I18n.t('curriculum.updated_failed_without_name')
        render(:action => 'edit')
      end
    end
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

  # GET /super_admin/curriculums/init_import
  def init_import

  end

  # POST /super_admin/curriculums/import
  def import
    begin      
      data_source = params[:import_file].path
      errors = Curriculum.import_data(data_source)
      if errors.blank?
        flash[:notice] = I18n.t("curriculum.import_successfully")
      else
        puts errors.inspect
        flash[:alert] = I18n.t("curriculum.import_failed")
      end
    rescue Exception => exc
      ::Util.log_error(exc, "SuperAdmin::CurriculumsController#import")
      flash[:alert] = I18n.t("curriculum.import_failed")
    end

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
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

    # To adapt the method #sortable in ApplicationHelper
    def sort_column
      if Curriculum::SORTABLE_MAP.keys.include?(params[:sort])
        params[:sort]
      else
        'curriculum_core'
      end
    end

    def actual_sort_column
      Curriculum::SORTABLE_MAP[sort_column]
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
    end

    def sort_criteria
      return "#{actual_sort_column} #{sort_direction}"
    end
end
