class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses do |t|
    	t.integer :goal_id, :null => false
      t.date :due_date, :null => false
      t.float :accuracy, :default => 0

      t.timestamps
    end

    add_index :progresses, :goal_id
  end
end
