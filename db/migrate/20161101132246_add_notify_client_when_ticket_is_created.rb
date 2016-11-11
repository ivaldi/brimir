class AddNotifyClientWhenTicketIsCreated < ActiveRecord::Migration
  def change
    unless column_exists? :tenants, :notify_client_when_ticket_is_created
      add_column :tenants, :notify_client_when_ticket_is_created, :boolean, default: false
    end
  end
end
