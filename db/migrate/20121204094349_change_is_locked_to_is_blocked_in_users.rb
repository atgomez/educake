class ChangeIsLockedToIsBlockedInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :is_locked, :is_blocked
  end
end
