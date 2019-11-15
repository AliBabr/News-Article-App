class Question < ApplicationRecord
  has_many :answer_options , dependent: :destroy
  validates :question, :points, :correct_option, presence: true
end
