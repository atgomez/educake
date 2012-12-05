class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.date :birthday, :null => false
      t.integer :teacher_id
      t.boolean :gender
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at

      t.timestamps
    end

    add_index :students, [:first_name, :last_name, :teacher_id], :unique => true
  end
end
