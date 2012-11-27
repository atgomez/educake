class RemoveIsIdealInStatuses < ActiveRecord::Migration
  def change
    remove_column :statuses, :is_ideal
  end
end
