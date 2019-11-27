class UpdateNewsFileds < ActiveRecord::Migration[5.2]
  def change
    remove_column :news, :website_address
    rename_column :news, :description, :news_tok
  end
end
