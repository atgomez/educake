module EducakeAPI::Helpers
  module FilterParams
    PAGE_SIZE = 20
    MAX_PAGE_SIZE = 100

    def default_page_size
      PAGE_SIZE
    end
    
    def do_filter_params
      # TODO: filter paging info and other necessary parameters.
      @filtered_params = params
      # Check the page_size params.
      if @filtered_params[:page_size].to_i <= 0
        @filtered_params[:page_size] = default_page_size
      elsif @filtered_params[:page_size].to_i > MAX_PAGE_SIZE
        @filtered_params[:page_size] = MAX_PAGE_SIZE
      end
      
      return @filtered_params
    end
    
    def filtered_params
      @filtered_params
    end
  end
end
