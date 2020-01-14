class CreateInstallments < ActiveRecord::Migration[5.2]
  def change
    create_table :installments do |t|
      t.string :name
      t.integer :amount
      t.string :currency
      t.string :interval
      t.string :plan_tok
      t.integer :interval_count

      t.timestamps
    end
  end
end
