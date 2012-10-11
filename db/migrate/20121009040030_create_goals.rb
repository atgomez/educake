class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer :student_id, :null => false
      t.integer :subject_id, :null => false
      t.integer :curriculum_id, :null => false
      t.date :due_date
      t.float :accuracy

      t.timestamps
    end

    add_index :goals, :subject_id
    add_index :goals, :curriculum_id
  end
end
