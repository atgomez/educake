module GoalsHelper
  # Check if all goal errors is on Curriculum nested attributes or not.
  def are_all_errors_on_curriculum?(goal)
    return false if (goal.blank? || goal.errors.blank?)
    return true if (goal.curriculum.blank? || goal.curriculum.curriculum_core_id.blank? || 
                                              goal.curriculum.subject_id.blank? ||
                                              goal.curriculum.curriculum_grade_id.blank? ||
                                              goal.curriculum.curriculum_area_id.blank? ||
                                              goal.curriculum.standard.blank?)

    curriculum_errors = 0
    goal.errors.keys.each do |k|
      key = k.to_s
      if key.start_with?("curriculum.") || key == "curriculum_id"
        curriculum_errors += 1
      end
    end
    return (curriculum_errors == goal.errors.keys.length)
  end

  def curriculum_standards_collection
    Curriculum.order(:standard).select("DISTINCT standard").collect{|c| [c.standard, c.standard]}
  end

  def curriculum_associations_for_goal(goal)
    curriculum = goal.curriculum
    if curriculum.blank? || curriculum.curriculum_core_id.blank?
      curriculum = Curriculum.first
    end

    return {} if curriculum.blank?    
    Curriculum.get_associations_by_fields('curriculum_core_id' => curriculum.curriculum_core_id)
  end

  # Detect if the current goal curriculum field shoule be diabled.
  def disable_goal_curriculum_field(previous_field_value, goal, curriculum_field_name)
    if goal.nil? || goal.curriculum.nil?
      return true
    end

    blank = goal.curriculum.send(curriculum_field_name).blank?
    if !previous_field_value.blank? && blank
      return false
    elsif previous_field_value.blank?
      return true
    end

    return blank
  end

  # Detect if the suitable value for goal curriculum field.
  def selected_value_for_goal_curriculum_field(previous_result, goal, curriculum_field_name)
    if goal.nil? || goal.curriculum.nil?
      return nil
    end

    if previous_result.blank?
      return nil
    else
      return goal.curriculum.send(curriculum_field_name)
    end
  end
end
