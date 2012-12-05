class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses do |t|
    	t.integer :goal_id, :null => false
      t.date :due_date, :null => false
      t.float :accuracy, :null => false, :default => 0.0

      t.timestamps
    end

    add_index :progresses, :goal_id
    add_index :progresses, :due_date
  end
end
