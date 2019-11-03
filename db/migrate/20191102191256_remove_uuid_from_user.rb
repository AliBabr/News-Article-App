class RemoveUuidFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :uuid
  end
end
