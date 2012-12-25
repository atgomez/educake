class CreateCurriculumAreas < ActiveRecord::Migration
  def change
    create_table :curriculum_areas do |t|
      t.string :name, :null => false

      t.timestamps
    end

    add_index :curriculum_areas, :name, :unique => true
  end
end
