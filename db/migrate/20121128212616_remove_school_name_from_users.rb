class RemoveSchoolNameFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :school_name
  end
end
