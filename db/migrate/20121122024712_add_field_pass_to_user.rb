class AddFieldPassToUser < ActiveRecord::Migration
  def change
    add_column :users, :temp_pass, :string
  end
end
