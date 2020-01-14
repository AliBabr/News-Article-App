class Plan < ApplicationRecord
  has_many :subscriptions
  has_many :installments
  validates :amount, :currency, :interval, :interval_count, :name, presence: true
end
