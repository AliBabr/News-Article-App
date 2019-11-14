class CreateCoupons < ActiveRecord::Migration[5.2]
  def change
    create_table :coupons do |t|
      t.string :duration
      t.integer :percent_off
      t.string :token
      t.string :description
      t.timestamps
    end
  end
end
