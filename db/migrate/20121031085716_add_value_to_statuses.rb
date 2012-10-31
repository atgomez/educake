class AddValueToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :value, :integer, :default => 0
    add_column :statuses, :ideal_value, :integer, :default => 0
    add_column :statuses, :time_to_complete, :time
  end
end
