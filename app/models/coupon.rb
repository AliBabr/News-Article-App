class Coupon < ApplicationRecord
  has_many :subscriptions
  validates :duration, :token, :percent_off, presence: true
end
