class CreateNews < ActiveRecord::Migration[5.2]
  def change
    create_table :news do |t|
      t.string :title
      t.string :website_address
      t.string :description
      t.string :url
      t.timestamps
    end
  end
end
