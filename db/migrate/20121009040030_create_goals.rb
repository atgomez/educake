class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer :subject_id
      t.integer :curriculum_id
      t.date :due_date
      t.float :accuracy

      t.timestamps
    end
  end
end
