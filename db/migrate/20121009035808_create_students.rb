class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :first_name
      t.string :last_name
      t.date :birthday
      t.integer :teacher_id
      t.boolean :gender

      t.timestamps
    end
  end
end
