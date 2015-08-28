class AddTimeZoneAndLocaleToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :default_time_zone, :string, default: 'Amsterdam'
    add_column :tenants, :ignore_user_agent_locale, :boolean, default: false, null: false
    add_column :tenants, :default_locale, :string, default: 'en'
    change_column_default :users, :time_zone, nil
  end
end
