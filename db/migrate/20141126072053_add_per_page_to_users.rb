class AddPerPageToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :per_page, :integer, default: 30, null: false
  end
end
