class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.is_admin?
      # Super admin
      can :manage, :all 
    elsif !user.new_record?
      alias_action  :show, :index, :search, :load_users, :load_status, :to => :read
      alias_action  :new_status, :add_status, :to => :create
      alias_action  :edit, :to => :update
      alias_action  :delete, :to => :destroy

      if user.is?(:admin)
        can :read, User
        can [:create, :update, :destroy], User do |a_user|
          # Only able to manage new user or the 'sub' user.
          (a_user.new_record? || a_user.parent_id == user.id)
        end
        can :mangage, [Curriculum, Goal, Status, Student, StudentSharing]
      elsif user.is?(:teacher)
        can :read, User
        can :mangage, [Curriculum, Goal, Status, Student, StudentSharing]
      elsif user.is?(:parent)
        can :read, [Curriculum, Goal, Status, Student, StudentSharing]
      end  
    end
  end
end
