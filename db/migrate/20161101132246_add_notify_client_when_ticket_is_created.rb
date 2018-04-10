class AddNotifyClientWhenTicketIsCreated < ActiveRecord::Migration[4.2]
  def change
    unless column_exists? :tenants, :notify_client_when_ticket_is_created
      add_column :tenants, :notify_client_when_ticket_is_created, :boolean, default: false
    end
  end
end
