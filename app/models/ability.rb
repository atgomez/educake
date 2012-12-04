class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.is_admin?
      # Super admin
      can :manage, :all 
    elsif !user.new_record?
      alias_action  :show, :index, :search, :load_users, :load_grade, :to => :read
      alias_action  :new_grade, :add_grade, :to => :create
      alias_action  :edit, :to => :update
      alias_action  :delete, :to => :destroy

      if user.is?(:admin)
        can :read, User
        can :manage, User do |a_user|
          # Only able to manage new user or the 'sub' user.
          (a_user.new_record? || a_user.parent_id == user.id)
        end
        can :mangage, [Curriculum, Goal, Grade, Student, StudentSharing]
      elsif user.is?(:teacher)
        can :read, User
        can :mangage, [Curriculum, Goal, Grade, Student, StudentSharing]
      elsif user.is?(:parent)
        can :read, [User, Curriculum, Goal, Student, StudentSharing]
        can :mangage, [Grade]
      end  
    end
  end
end
