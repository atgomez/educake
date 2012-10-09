class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.integer :goal_id, :null => false
      t.date :due_date
      t.float :accuracy

      t.timestamps
    end

    add_index :statuses, :goal_id
  end
end
