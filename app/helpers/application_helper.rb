module ApplicationHelper
  
   def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
  
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
  
  def roles(user)
    user_roles = []
    if user.is_super_admin?
      user_roles = Role.order("name ASC").where(:name => "Admin")
    elsif user.is?(:admin)
      user_roles = Role.order("name ASC").where(:name => "Teacher")
    elsif user.is?(:teacher)
      user_roles = Role.order("name ASC").where(:name => "Teacher")
      user_roles += Role.order("name ASC").where(:name => "Parent")
    end
    return user_roles
  end
  
  def emails(user)
    user_emails = []
    if user.is_super_admin?
      user_emails = (StudentSharing.joins(:role).where("roles.name = ?", "Admin").map(&:email) + User.joins(:role).where("roles.name = ?", "Admin").map(&:email)).uniq.sort
    elsif user.is?(:admin)
      user_emails = (StudentSharing.joins(:role).where("roles.name = ?", "Teacher").map(&:email) + User.joins(:role).where("roles.name = ?", "Teacher").map(&:email)).uniq.sort
    elsif user.is?(:teacher) 
      user_emails = (StudentSharing.joins(:role).where("roles.name = ? or roles.name = ?", "Teacher", "Parent").map(&:email) + User.joins(:role).where("roles.name = ? or roles.name = ?", "Teacher", "Parent").map(&:email)).uniq.sort
    end
    return user_emails
  end 
end
