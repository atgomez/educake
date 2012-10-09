class CreateCurriculums < ActiveRecord::Migration
  def change
    create_table :curriculums do |t|
      t.string :name, :null => false

      t.timestamps
    end

    add_index :curriculums, :name, :unique => true
  end
end
