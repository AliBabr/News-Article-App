class AddShippingInfoIntoSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :first_name, :string
    add_column :subscriptions, :last_name, :string
    add_column :subscriptions, :street_address, :string
    add_column :subscriptions, :city, :string
    add_column :subscriptions, :state, :string
    add_column :subscriptions, :zip_code, :integer
  end
end
