class SuperAdmin::CurriculumsController < SuperAdmin::BaseSuperAdminController
  helper_method :sort_column, :sort_direction, :sort_criteria

  def index
    load_params = filtered_params.merge({
      :sort_criteria => sort_criteria
    })
    @curriculums = Curriculum.load_data(load_params)
  end

  def new
    @curriculum = Curriculum.init_curriculum
  end

  def create
    begin
      @curriculum = Curriculum.new(params[:curriculum])
      if @curriculum.save
        flash[:notice] = I18n.t("curriculum.created_successfully", :name => @curriculum.name)
        redirect_to :action => 'index'
      else
        render(:action => 'new')
      end
    rescue Exception => exc
      ::Util.log_error(exc, "SuperAdmin::CurriculumsController#create")
      flash.now[:alert] = I18n.t('curriculum.updated_failed_without_name')
      if @curriculum.blank?
        @curriculum = Curriculum.init_curriculum
      end
      render(:action => 'new')
    end
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
    @import = CurriculumImport.init_import
  end

  # POST /super_admin/curriculums/import
  # TODO: should use Timeout and DelayedJob
  def import
    attrs = params[:curriculum_import] || {}
    @import = CurriculumImport.new(attrs)

    begin      
      if @import.valid?
        result = Curriculum.import_data(@import.import_file_path, 
                              :curriculum_core_name => @import.curriculum_core_name)
        if result[:errors].blank?
          flash[:notice] = I18n.t("curriculum.import_successfully")
        else          
          flash[:alert] = generate_import_errors(result)
        end      
      end
    rescue Exception => exc
      ::Util.log_error(exc, "SuperAdmin::CurriculumsController#import")
      flash[:alert] = I18n.t("curriculum.import_failed")
    end

    respond_to do |format|
      format.js
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

    # Generate human friendly error message for import result.
    def generate_import_errors(import_result)
      return nil if import_result.blank?
      html = ""
      imported_num = import_result[:imported_num].to_i
      if imported_num == 1
        html << "<p>#{I18n.t("curriculum.import_successfully_with_one_line")}</p>"
      elsif imported_num > 1
        html << "<p>#{I18n.t("curriculum.import_successfully_with_lines", :num => imported_num)}</p>"
      end
      errors = import_result[:errors]
      unless errors.blank?
        html << I18n.t("curriculum.import_failed_with_error")
        html << "<ul>"
        count = 0
        errors.each do |line_num, message|
          break if count >= 5 # Only show 5 error messages
          html << "<li>#{I18n.t("curriculum.import_line_error", :num => line_num, :message => message)}</li>"
          count += 1
        end
        html << "</ul>"
      end
      return html.html_safe
    end 
end
