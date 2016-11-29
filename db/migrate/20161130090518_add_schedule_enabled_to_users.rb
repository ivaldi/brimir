class AddScheduleEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :schedule_enabled, :boolean, default: false
  end
end
