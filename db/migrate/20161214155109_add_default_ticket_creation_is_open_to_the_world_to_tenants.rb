class AddDefaultTicketCreationIsOpenToTheWorldToTenants < ActiveRecord::Migration
  def up
    change_column :tenants, :ticket_creation_is_open_to_the_world, :boolean, default: true
    Tenant.where(ticket_creation_is_open_to_the_world: nil).update_all(ticket_creation_is_open_to_the_world: true)
  end

  def down
    change_column :tenants, :ticket_creation_is_open_to_the_world, :boolean, default: nil
    Tenant.where(ticket_creation_is_open_to_the_world: true).update_all(ticket_creation_is_open_to_the_world: nil)
  end
end
