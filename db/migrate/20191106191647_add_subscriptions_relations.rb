class AddSubscriptionsRelations < ActiveRecord::Migration[5.2]
  def change
    add_reference(:subscriptions, :user, index: false)
    add_reference(:subscriptions, :plan, index: false)
  end
end
