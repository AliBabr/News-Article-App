class AddTotalDaysIntoPoll < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :days_left, :integer
    add_column :polls, :result_day, :datetime
  end
end
