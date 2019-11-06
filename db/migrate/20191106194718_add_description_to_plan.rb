class AddDescriptionToPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :description, :string
  end
end
