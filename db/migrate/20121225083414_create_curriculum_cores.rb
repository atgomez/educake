class CreateCurriculumCores < ActiveRecord::Migration
  def change
    create_table :curriculum_cores do |t|
      t.string :name, :null => false

      t.timestamps
    end

    add_index :curriculum_cores, :name, :unique => true
  end
end
