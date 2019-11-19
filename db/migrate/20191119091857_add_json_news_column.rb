class AddJsonNewsColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :news, :data, :jsonb
  end
end
