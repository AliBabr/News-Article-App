class RenamePlaneId < ActiveRecord::Migration[5.2]
  def change
    rename_column :plans, :plan_id, :plan_tok
  end
end
