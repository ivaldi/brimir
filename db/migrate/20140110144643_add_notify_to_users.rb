class AddNotifyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notify, :boolean, default: true
  end
end
