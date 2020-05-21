class AddAptIntoSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :country, :string
    add_column :subscriptions, :apt, :string
  end
end
