class RemanePollDaysLeftToTotalDays < ActiveRecord::Migration[5.2]
  def change
    rename_column :polls, :days_left, :total_days
  end
end
