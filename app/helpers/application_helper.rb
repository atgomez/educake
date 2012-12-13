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
      user_roles = [Role[:admin]]
    elsif user.is?(:teacher) || user.is?(:admin)
      # NOTE: use Role.with_name(*name) if there are more than 2 roles
      user_roles = [Role[:teacher], Role[:parent]]
    end
    return user_roles
  end
  
  def emails(user)
    user_emails = []
    if user.is_super_admin?
      user_emails = (StudentSharing.unblocked.joins(:role).where("roles.name = ?", "Admin").map(&:email) + User.unblocked.joins(:role).where("roles.name = ?", "Admin").map(&:email)).uniq.sort
    elsif user.is?(:teacher) || user.is?(:admin)
      user_emails = (StudentSharing.unblocked.joins(:role).where("roles.name = ? or roles.name = ?", "Teacher", "Parent").map(&:email) + User.unblocked.joins(:role).where("roles.name = ? or roles.name = ?", "Teacher", "Parent").map(&:email)).uniq.sort
    end
    return user_emails
  end

  def profile_back_link_text(user = nil)
    user ||= current_user
    result = ""
    if user.is_super_admin?
      result = I18n.t("profile.back_link_text.super_admin")
    else
      result = user.role.try(:name).to_s.underscore
      result = I18n.t("profile.back_link_text.#{result}")
    end
    return result
  end
end
