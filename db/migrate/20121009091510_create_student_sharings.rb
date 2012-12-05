class CreateStudentSharings < ActiveRecord::Migration
  def change
    create_table :student_sharings do |t|
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.string :email, :null => false      
      t.integer :student_id, :null => false
      t.integer :user_id
      t.integer :role_id, :null => false
      t.string :confirm_token

      t.timestamps
    end

    add_index :student_sharings, [:email, :student_id], :unique => true
    add_index :student_sharings, :role_id
    add_index :student_sharings, :student_id
    add_index :student_sharings, :user_id
    add_index :student_sharings, :confirm_token
  end
end
