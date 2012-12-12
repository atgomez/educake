class AddFieldToStudentSharing < ActiveRecord::Migration
  def change
    add_column :student_sharings, :is_blocked, :boolean, :default => false
  end
end
