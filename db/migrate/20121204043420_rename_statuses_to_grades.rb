class RenameStatusesToGrades < ActiveRecord::Migration
  def up
  	rename_table :statuses, :grades
  end

  def down
  	rename_table :grades, :statuses
  end
end
