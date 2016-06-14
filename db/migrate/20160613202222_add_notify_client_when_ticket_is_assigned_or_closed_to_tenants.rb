class AddNotifyClientWhenTicketIsAssignedOrClosedToTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :notify_client_when_ticket_is_assigned_or_closed, :boolean
  end
end
