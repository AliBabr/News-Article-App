class Plan < ApplicationRecord
  has_many :subscriptions
  validates :plan_tok, :name, presence: true
end
