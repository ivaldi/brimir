class AddScheduleEnabledToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :schedule_enabled, :boolean, default: false
  end
end
