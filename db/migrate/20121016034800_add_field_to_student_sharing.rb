class AddFieldToStudentSharing < ActiveRecord::Migration
  def change
    remove_column :student_sharings, :name 
    add_column :student_sharings, :confirm_token, :string
    add_column :student_sharings, :first_name, :string
    add_column :student_sharings, :last_name, :string
  end
end
