module ApplicationHelper
  # Render pagination section.
  # The data_source must be paginated by Will_paginate or Kaminari
  def render_pagination(data_source, paging_params = {}, options = {})
    return nil if data_source.blank?
    will_paginate(data_source, options.merge({
      :previous_label => "<",
      :next_label => ">",
      :param_name => "page_id",
      :params => paging_params
    }))
  end
end
