class CreateCurriculumGrades < ActiveRecord::Migration
  def change
    create_table :curriculum_grades do |t|
      t.string :name, :null => false

      t.timestamps
    end

    add_index :curriculum_grades, :name, :unique => true
  end
end
