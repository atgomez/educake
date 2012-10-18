class AddIsCompletedToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :is_completed, :boolean
  end
end
