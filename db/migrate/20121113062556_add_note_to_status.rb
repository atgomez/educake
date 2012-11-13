class AddNoteToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :note, :text
  end
end
