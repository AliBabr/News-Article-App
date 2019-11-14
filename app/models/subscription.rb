class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  belongs_to :coupon, optional: true
end
