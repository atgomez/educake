class AddFileToGoal < ActiveRecord::Migration
  def change
     add_attachment :goals, :grades
  end
end
