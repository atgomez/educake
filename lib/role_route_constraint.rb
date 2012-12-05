class RoleRouteConstraint
  def initialize(*roles)
    # Convert all params to string
    @roles = roles.map{|r| r.to_s}
  end

  def matches?(request)
    user = request.env['warden'].user
    puts "======== Warden ======", request.env['warden'].inspect
    unless user.blank?
      user_role = user.role.try(:name).to_s.gsub(" ", "").underscore
      result = @roles.include?(user_role)
      result = result || (@roles.include?('super_admin') && user.is_super_admin?)

      puts "======== RESR ======", result
      return result
    end
  end
end
