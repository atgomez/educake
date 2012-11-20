class AddSchoolToUser < ActiveRecord::Migration
  def change
    add_column :users, :school_id, :integer
    add_column :users, :notes, :text
  end
end
