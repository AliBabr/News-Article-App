class Plan < ApplicationRecord
  has_many :subscriptions
  validates :amount, :currency, :interval, :interval_count, :name, presence: true
end
