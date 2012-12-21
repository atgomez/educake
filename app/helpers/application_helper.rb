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
    if user.is?(:teacher) || user.is?(:admin)
      role_ids = [ Role[:parent].id, Role[:teacher].id ]
      # Generate SQL for joining table, do not 
      join_sql = User.send(:sanitize_sql, [
        "LEFT JOIN student_sharings ON student_sharings.user_id = users.id
                  AND student_sharings.is_blocked = ?", false
      ])

      # Get the sharing_students email and user email
      # This is a trick because sharing_students email is stored in User object!
      users = user.school.users.unblocked.joins(join_sql).where(
        "users.role_id IN(?)", role_ids
      ).select("users.email, student_sharings.email AS sharing_email")
      users.each do |u|
        user_emails << u['email']
        user_emails << u['sharing_email'] unless u['sharing_email'].blank?
      end
      user_emails.uniq!
      user_emails.sort!
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

  def genders_collection_for_select
    [[true, t("common.gender.male")], [false, t("common.gender.female")]]
  end
end
