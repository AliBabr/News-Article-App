class AddPollsRelations < ActiveRecord::Migration[5.2]
  def change
    add_reference(:answer_options, :poll, index: false)
  end
end
