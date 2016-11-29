class AddOpenToTheWorldToTenants < ActiveRecord::Migration
  def change
    unless column_exists? :tenants, :ticket_creation_is_open_to_the_world
      add_column :tenants, :ticket_creation_is_open_to_the_world, :boolean, nil: false
    end
  end
end
