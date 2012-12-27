class CreateCurriculums < ActiveRecord::Migration
  def change
    create_table :curriculums do |t|
      t.integer :curriculum_core_id, :null => false
      t.integer :subject_id, :null => false
      t.integer :curriculum_grade_id, :null => false
      t.integer :curriculum_area_id, :null => false
      t.integer :standard, :null => false
      t.string :description1, :null => false
      t.text :description2, :null => false

      t.timestamps
    end

    add_index :curriculums, [ :curriculum_core_id, :subject_id, :curriculum_grade_id,
                              :curriculum_area_id, :standard], 
                          :name => "curriculums_unique_index",
                          :unique => true
  end
end
