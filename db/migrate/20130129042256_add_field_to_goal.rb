class AddFieldToGoal < ActiveRecord::Migration
  def change
    add_column :goals, :goal_x, :integer, :null => false, :default => 0
    add_column :goals, :goal_y, :integer, :null => false, :default => 0
    add_column :goals, :baseline_x, :integer, :null => false, :default => 0
    add_column :goals, :baseline_y, :integer, :null => false, :default => 0
    add_column :goals, :is_percentage, :boolean, :default => true
  end
end
