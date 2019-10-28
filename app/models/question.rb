class Question < ApplicationRecord
  has_many :answer_options , dependent: :destroy
end
