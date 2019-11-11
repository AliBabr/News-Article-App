class ChangeSubscriptionUserIdType < ActiveRecord::Migration[5.2]
  def change
    change_column :subscriptions, :user_id, :string
  end
end
