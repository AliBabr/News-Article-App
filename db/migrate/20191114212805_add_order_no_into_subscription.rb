class AddOrderNoIntoSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :order_no, :string
  end
end
