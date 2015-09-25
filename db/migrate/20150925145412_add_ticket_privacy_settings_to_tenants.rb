class AddTicketPrivacySettingsToTenants < ActiveRecord::Migration
  def change
    if Tenant.postgresql?
      old = Tenant.connection.schema_search_path
      Tenant.connection.schema_search_path = 'public'
    end

    unless column_exists? :tenants, :require_authenticated_user
      add_column :tenants, :require_authenticated, :boolean,
          default: false, null: false
      add_column :tenants, :require_authenticated_ip_whitelist, :string
    end

    if Tenant.postgresql?
      Tenant.connection.schema_search_path = old
    end
  end
end
