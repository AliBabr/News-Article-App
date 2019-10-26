class AddCategoryToNews < ActiveRecord::Migration[5.2]
  def change
    add_column :news, :category, :integer
  end
end
