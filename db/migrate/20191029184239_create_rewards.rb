class CreateRewards < ActiveRecord::Migration[5.2]
  def change
    create_table :rewards do |t|
      t.string :title
      t.string :latitude
      t.string :longitude
      t.string :address
      t.string :shop_name
      t.timestamps
    end
  end
end
