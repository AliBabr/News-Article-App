class AddLoginRewardColumnIntoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :login_count, :integer
    add_column :users, :login_time, :datetime
  end
end
