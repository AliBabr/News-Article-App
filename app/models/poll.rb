class Poll < ApplicationRecord
  has_many :answer_options , dependent: :destroy
  validates :poll_question, presence: true
end
