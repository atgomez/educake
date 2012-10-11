class CreateStudentSharings < ActiveRecord::Migration
  def change
    create_table :student_sharings do |t|
      t.string :name, :null => false
      t.string :email, :null => false
      t.integer :role_id
      t.integer :student_id, :null => false
      t.integer :user_id

      t.timestamps
    end

    add_index :student_sharings, :name
    add_index :student_sharings, :email
    add_index :student_sharings, :role_id
    add_index :student_sharings, :student_id
    add_index :student_sharings, :user_id
  end
end
