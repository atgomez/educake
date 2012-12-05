class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer :student_id, :null => false
      t.integer :subject_id, :null => false
      t.integer :curriculum_id, :null => false      
      t.float :accuracy, :null => false, :default => 0.0
      t.float :baseline, :null => false, :default => 0.0
      t.date :baseline_date, :null => false
      t.date :due_date, :null => false
      t.integer :trial_days_total, :null => false
      t.integer :trial_days_actual, :null => false
      t.string :grades_data_file_name
      t.string :grades_data_content_type
      t.integer :grades_data_file_size
      t.datetime :grades_data_updated_at
      t.text :description
      t.boolean :is_completed, :default => false

      t.timestamps
    end

    add_index :goals, :student_id
    add_index :goals, :subject_id
    add_index :goals, :curriculum_id
    add_index :goals, :baseline_date
    add_index :goals, :due_date
  end
end
