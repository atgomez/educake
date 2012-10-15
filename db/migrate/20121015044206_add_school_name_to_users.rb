class AddSchoolNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :school_name, :string
  end
end
