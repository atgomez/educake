class RemoveTempPassInUsers < ActiveRecord::Migration
  def change
    remove_column :users, :temp_pass
    remove_column :users, :confirm_token
  end
end
