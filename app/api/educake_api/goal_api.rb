module EducakeAPI
  class GoalAPI < Grape::API
    helpers do
      def find_student(id)
        student = current_user.accessible_students.find_by_id(id)
        error!('Student not found', 404) unless student
        student
      end

      def find_goal(id)
        goal = Goal.incomplete.find_by_id(id)
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
        optional :page_size, :type => Integer, :desc => "Size for pagination"
        optional :page_id, :type => Integer, :desc => "Page index"
      end
      get "/:student_id" do
        @student = find_student(params[:student_id])
        @goals = @student.goals.load_data(filtered_params)
        @current_page = check_page_id(@goals.total_pages)
        {:data => @goals, :total_pages => @goals.total_pages, :current_page => @current_page}
      end

      #
      # Add grade
      #

      desc "Add grade for a goal"
      params do
        requires :goal_id, :type => Integer, :desc => "Goal ID"
        requires :due_date, :api_date => true, :desc => "Due date"
        requires :accuracy, :type => Float, :desc => "Accuracy"
        optional :time_to_complete, :type => Time, :desc => "Time to complete"
        optional :note, :type => String, :desc => "Some more extra description"
      end
      post "/:goal_id/add_grade" do
        @goal = find_goal(params[:goal_id])
        attrs = {}
        [:due_date, :accuracy, :time_to_complete, :note].each do |key|
          attrs[key] = params[key]
        end
        attrs[:user_id] = current_user.id

        @grade = @goal.grades.new(attrs)
        unless @grade.valid?
          error!(@grade.errors.full_messages, 400)
        else
          Grade.transaction do
            @grade = @goal.build_grade(attrs)

            if (@grade)
              @grade = @goal.update_grade_state(@grade)
              if @grade.save
                @goal.update_all_grade
                status 201
              else
                error!(@grade.errors.full_messages, 400)
              end
            end
          end          
        end

        # Success
        @grade
      end
    end
  end
end
