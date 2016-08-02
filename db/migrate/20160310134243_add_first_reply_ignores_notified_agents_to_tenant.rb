class AddFirstReplyIgnoresNotifiedAgentsToTenant < ActiveRecord::Migration
  def change
    unless column_exists?(:tenants, :first_reply_ignores_notified_agents)
      add_column :tenants, :first_reply_ignores_notified_agents, :boolean, default: false, null: false
    end
  end
end
