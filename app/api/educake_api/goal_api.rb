module EducakeAPI
  class GoalAPI < Grape::API
    helpers do
      def find_student(id)
        student = current_user.accessible_students.find_by_id(id)
        error!('Student not found', 404) unless student
        student
      end

      def find_goal(id)
        goal = Goal.find_by_id(id)
        error!('Goal not found', 404) unless goal

        # Check if the current user can access the goal
        if current_user.is_not_admin?
          student = current_user.accessible_students.find_by_id(goal.student_id)
          error!('You are not authorize to access this goal', 403) unless student
        end
        goal
      end
    end

    resource :goals do
      #
      # List grades
      #

      desc "Get list goals"
      params do
        requires :student_id, :type => Integer, :desc => "Student ID"
      end
      get "/:student_id" do
        @student = find_student(params[:student_id])
        @goals = @student.goals.load_data(filtered_params)
        @current_page = filtered_params[:page_id] || 1
        {:data => @goals, :total_pages => @goals.total_pages, :current_page => @current_page}
      end

      #
      # Add grade
      #

      desc "Add grade for a goal"
      params do
        requires :goal_id, :type => Integer, :desc => "Goal ID"
        requires :due_date, :type => Date, :desc => "Due date"
        requires :accuracy, :type => Float, :desc => "Accuracy"
      end
      post "/:goal_id/add_grade" do
        @goals = find_goal(params[:goal_id])
        attrs = {}
        [:due_date, :accuracy, :time_to_complete, :note].each do |key|
          attrs[key] = params[key]
        end
        attrs[:user_id] = current_user.id
        @grade = @goals.grades.new(attrs)

        if @grade.save
          @grade
        else
          {:error => @grade.errors.full_messages}
        end
      end
    end
  end
end
