class CreateAnswerOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :answer_options do |t|
      t.string :answer
      t.timestamps
      t.references :question, index: true, foreign_key: true
    end
  end
end
