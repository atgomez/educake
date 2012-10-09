class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :name, :null => false
      t.string :email, :null => false
      t.integer :role_id
      t.integer :student_id, :null => false

      t.timestamps
    end

    add_index :invitations, :name
    add_index :invitations, :email
    add_index :invitations, :role_id
    add_index :invitations, :student_id
  end
end
