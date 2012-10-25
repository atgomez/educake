class AddFieldToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :is_ideal, :boolean, :default => true
    add_column :statuses, :user_id, :integer
  end
end
