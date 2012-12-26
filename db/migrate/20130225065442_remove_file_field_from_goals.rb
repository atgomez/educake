class RemoveFileFieldFromGoals < ActiveRecord::Migration
  def change
  	remove_column :goals, :grades_data_file_name
    remove_column :goals, :grades_data_content_type
    remove_column :goals, :grades_data_file_size
    remove_column :goals, :grades_data_updated_at
  end
end
