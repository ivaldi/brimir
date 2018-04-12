class AddNotifyToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :notify, :boolean, default: true
  end
end
