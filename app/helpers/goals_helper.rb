module GoalsHelper
  # Check if all goal errors is on Curriculum nested attributes or not.
  def are_all_errors_on_curriculum?(goal)
    return false if (goal.blank? || goal.errors.blank?)
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

  def curriculum_associtions_for_goal(goal)
    curriculum = goal.curriculum
    if curriculum.blank?
      curriculum = Curriculum.first
    end

    Curriculum.get_associations_by_field('curriculum_core_id', curriculum.curriculum_core_id)
  end
end
