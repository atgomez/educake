class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.string :email
      t.boolean :is_accept, :default => false
      t.timestamps
    end
  end
end
