class AddImageToStudent < ActiveRecord::Migration
  def change
    add_attachment :students, :photo
  end
end
