class AddSubscriptionsIds < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :subscription_tok, :string
  end
end
