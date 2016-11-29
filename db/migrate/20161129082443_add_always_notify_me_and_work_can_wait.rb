class AddAlwaysNotifyMeAndWorkCanWait < ActiveRecord::Migration
  def change
    unless column_exists? :tenants, :always_notify_me
      add_column :tenants, :always_notify_me, :boolean, default: true
    end
    unless column_exists? :tenants, :work_can_wait
      add_column :tenants, :work_can_wait, :boolean, default: false
    end
  end
end
