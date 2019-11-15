class AnswerOption < ApplicationRecord
  belongs_to :question, optional: true
  belongs_to :poll, optional: true
end
