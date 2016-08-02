class AddNotifyClientWhenTicketIsAssignedOrClosedToTenants < ActiveRecord::Migration
  def change
    unless column_exists? :tenants, :notify_client_when_ticket_is_assigned_or_closed
      add_column :tenants, :notify_client_when_ticket_is_assigned_or_closed, :boolean, default: false, null: false
    end
  end
end
