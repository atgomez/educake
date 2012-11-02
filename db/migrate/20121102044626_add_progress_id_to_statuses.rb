class AddProgressIdToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :progress_id, :integer
  end
end
