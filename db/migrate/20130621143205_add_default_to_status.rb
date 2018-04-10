class AddDefaultToStatus < ActiveRecord::Migration[4.2]
  def change
    add_column :statuses, :default, :boolean, default: false
  end
end
