class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :name, :null => false

      t.timestamps
    end

    add_index :subjects, :name, :unique => true
  end
end
