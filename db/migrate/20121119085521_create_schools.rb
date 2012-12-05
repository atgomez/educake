class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name, :null => false
      t.string :address1, :null => false
      t.string :address2
      t.string :city
      t.string :state, :null => false
      t.string :zipcode
      t.string :phone, :null => false

      t.timestamps
    end

    add_index :schools, [:name, :city], :unique => true
    add_index :schools, [:name, :state], :unique => true
  end
end
