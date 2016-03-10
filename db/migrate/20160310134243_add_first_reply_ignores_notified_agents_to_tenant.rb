class AddFirstReplyIgnoresNotifiedAgentsToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :first_reply_ignores_notified_agents, :boolean, default: false, null: false
  end
end
