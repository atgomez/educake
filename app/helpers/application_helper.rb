module ApplicationHelper
  # Get the current tab
  def current_tab
    @current_tab ||= "home"
  end

  def set_current_tab(item)
    (current_tab.to_s == item.to_s) ? "active" : ""
  end

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
  
  def roles(role)
    user_roles = []
    if role == "Super Admin"
      user_roles = Role.order("name ASC").where(:name => "Admin")
    elsif role == "Admin"
      user_roles = Role.order("name ASC").where(:name => "Teacher")
    elsif role == "Teacher"
      user_roles = Role.order("name ASC").where(:name => "Teacher")
      user_roles += Role.order("name ASC").where(:name => "Parent")
    end
    return user_roles
  end 
end
