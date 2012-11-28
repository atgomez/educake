class RemoveIsArchiveFromGoals < ActiveRecord::Migration
  def change
  	remove_column :goals, :is_archived
  end
end
