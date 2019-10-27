class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.string :question
      t.integer :points
      t.integer :correct_option
      t.string :total_days
      t.timestamps
    end
  end
end
