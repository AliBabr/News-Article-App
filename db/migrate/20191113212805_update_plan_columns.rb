class UpdatePlanColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :plans, :price, :amount
    rename_column :plans, :duration, :interval
    change_column :plans, :id, :string
    add_column :plans, :interval_count, :integer
  end
end
