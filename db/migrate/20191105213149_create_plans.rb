class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :price
      t.string :currency
      t.string :duration
      t.string :plan_id
      t.timestamps
    end
  end
end
