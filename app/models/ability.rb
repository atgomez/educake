class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.is_super_admin?
      # Super admin
      can :manage, :all 
    elsif !user.new_record?
      alias_action  :show, :index, :search, :load_users, :load_grade, 
                    :user_chart, :student_chart, :goal_chart, :all, :get_students,
                    :initial_import_grades, :load_grades, :search_user, :all_students, :to => :read
      alias_action  :new_grade, :add_grade, :import_grades, :to => :create
      alias_action  :edit, :update_grade, :to => :update
      alias_action  :delete, :to => :destroy

      if user.is?(:admin)
        can :read, User
        can :manage, User do |a_user|
          # Only able to manage new user or the 'sub' user.
          (a_user.new_record? || a_user.parent_id == user.id)
        end
        can :manage, [Curriculum, Goal, Grade, Student, StudentSharing]
      elsif user.is?(:teacher)
        can :read, User
        can :manage, [Curriculum, Goal, Grade, Student, StudentSharing]
      elsif user.is?(:parent)
        can :read, [User, Curriculum, Goal, Student, StudentSharing]
        can :manage, [Grade]
      end  
    end

    # View Auth - In case we need to know current user has any ability to view user's info or not
    can :view, User do |user_inview|
      if user.is_super_admin?
        !user_inview.is_super_admin?
      elsif user.is?(:admin)
        if user.id == user_inview.id 
          true
        elsif (user_inview.is?(:teacher) || user_inview.is?(:parent))
          user.id == user_inview.parent_id 
        else
          false
        end
      else
        user.id == user_inview.id
      end
    end
  end
end
