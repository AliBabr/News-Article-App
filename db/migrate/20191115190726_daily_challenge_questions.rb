class DailyChallengeQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :answer_options, :votes, :integer
    remove_column :questions, :total_days
    remove_column :questions, :question_type
    remove_column :questions, :is_active
  end
end
