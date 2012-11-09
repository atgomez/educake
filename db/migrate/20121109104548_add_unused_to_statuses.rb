class AddUnusedToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :is_unused, :boolean, :default => false
  end
end
