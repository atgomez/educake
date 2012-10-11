class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.date :birthday
      t.integer :teacher_id
      t.boolean :gender

      t.timestamps
    end

    add_index :students, [:first_name, :last_name, :teacher_id], :unique => true
  end
end
