class ChangeIntegerToFloat < ActiveRecord::Migration
  def change
  	change_column(:statuses, :value, :float, :default => 0)
  	change_column(:statuses, :ideal_value, :float, :default => 0)
  	change_column(:goals, :accuracy, :float, :default => 0)
  	change_column(:goals, :baseline, :float, :default => 0)
  end

end
