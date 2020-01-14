class InstallmentIdTypeAndRelationType < ActiveRecord::Migration[5.2]
  def change
    change_column :installments, :plan_id, :string
    change_column :installments, :id, :string
  end
end
