class AddCouponIntoSubscription < ActiveRecord::Migration[5.2]
  def change
    add_reference(:subscriptions, :coupon, index: false)
    change_column :subscriptions, :plan_id, :string
  end
end
