class AddSchoolToUser < ActiveRecord::Migration
  def change
    add_column :users, :school_id, :integer
    add_column :users, :notes, :text
    add_column :users, :confirm_token, :string
  end
end
