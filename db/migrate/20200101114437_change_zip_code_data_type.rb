class ChangeZipCodeDataType < ActiveRecord::Migration[5.2]
  def change
    change_column :subscriptions, :zip_code, :string
    change_column :users, :zip_code, :string
  end
end
