class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.integer :goal_id
      t.date :due_date
      t.float :accuracy

      t.timestamps
    end
  end
end
