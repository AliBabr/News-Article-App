class AddNumberIntoPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :plan_number, :integer
  end
end
