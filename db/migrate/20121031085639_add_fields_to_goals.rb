class AddFieldsToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :baseline, :integer, :default => 0
    add_column :goals, :baseline_date, :date, :null => false, :default => Time.now.to_date
    add_column :goals, :trial_days_total, :integer, :default => 0
    add_column :goals, :trial_days_actual, :integer, :default => 0
    add_column :goals, :is_archived, :bool, :default => false
  end
end
