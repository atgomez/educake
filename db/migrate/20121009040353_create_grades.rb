class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.integer :goal_id, :null => false
      t.integer :user_id
      t.integer :progress_id
      t.date :due_date, :null => false
      t.float :accuracy, :null => false, :default => 0.0
      t.float :value, :default => 0.0
      t.float :ideal_value, :default => 0.0
      t.time :time_to_complete
      t.boolean :is_unused, :default => false
      t.text :note

      t.timestamps
    end

    add_index :grades, :goal_id
    add_index :grades, :user_id
    add_index :grades, :progress_id
    add_index :grades, :due_date
  end
end
