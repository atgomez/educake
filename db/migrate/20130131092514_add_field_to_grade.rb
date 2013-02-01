class AddFieldToGrade < ActiveRecord::Migration
  def change
  	add_column :grades, :goal_x, :integer, :null => false, :default => 0
    add_column :grades, :goal_y, :integer, :null => false, :default => 0
  end
end
