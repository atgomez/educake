class ChangeAccuracyInStatuses < ActiveRecord::Migration
  def change
  	change_column(:statuses, :accuracy, :integer, :default => 0)
  end
end
