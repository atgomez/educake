class RenameGoalGradeAttachment < ActiveRecord::Migration
  def change
  	rename_column :goals, :grades_file_name, :grades_data_file_name
  	rename_column :goals, :grades_content_type, :grades_data_content_type
  	rename_column :goals, :grades_file_size, :grades_data_file_size
  	rename_column :goals, :grades_updated_at, :grades_data_updated_at
  end
end
