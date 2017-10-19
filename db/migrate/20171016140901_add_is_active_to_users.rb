class AddIsActiveToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :active, :boolean, default: true, null: false
  end
end
