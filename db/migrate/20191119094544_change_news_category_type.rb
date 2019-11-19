class ChangeNewsCategoryType < ActiveRecord::Migration[5.2]
  def change
    change_column :news, :category, :string
  end
end
