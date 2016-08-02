class AddTimeZoneAndLocaleToTenant < ActiveRecord::Migration
  def change
    if Tenant.postgresql?
      old = Tenant.connection.schema_search_path
      Tenant.connection.schema_search_path = 'public'
    end

    unless column_exists? :tenants, :default_time_zone
      add_column :tenants, :default_time_zone, :string, default: 'Amsterdam'
      add_column :tenants, :ignore_user_agent_locale, :boolean, default: false, null: false
      add_column :tenants, :default_locale, :string, default: 'en'
    end

    if Tenant.postgresql?
      Tenant.connection.schema_search_path = old
    end

    change_column_default :users, :time_zone, nil
  end
end
