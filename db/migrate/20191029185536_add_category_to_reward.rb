class AddCategoryToReward < ActiveRecord::Migration[5.2]
  def change
    add_column :rewards, :description, :string
    add_column :rewards, :category, :integer
  end
end
