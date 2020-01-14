class InstalmentRelation < ActiveRecord::Migration[5.2]
  def change
    add_reference(:installments, :plan, index: false)
  end
end
