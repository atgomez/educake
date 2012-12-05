# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ActiveRecord::Base
  ROLE_NAMES = %w[admin teacher parent]
  attr_accessible :name  

  # Hash used to cache roles.
  @cached_roles = {}

  # ASSOCIATION
  has_many :student_sharings, :dependent => :restrict
  has_many :users, :dependent => :restrict

  # SCOPE
  scope :with_name, lambda { |*names|
    names.map!{|n| n.to_s.titleize}
    where(:name => names)
  }

  class << self
    # Returns the role with given name
    # Alias for Role.get(name)
    def [](name)
      self.get(name)
    end

    def get(name, reload = false)
      name = name.to_s
      role = @cached_roles[name]
      (!role.nil? && !reload) ? role : (@cached_roles[name] = find_with_name(name))
    end

    def clear_caches
      @cached_roles = {}
    end

    protected     

      # Returns the Role instance within the given name
      # Auto 'titleize' the name.
      def find_with_name(name)
        name = name.to_s.titleize
        find_by_name(name)
      end
      
  end # End class methods.

end
