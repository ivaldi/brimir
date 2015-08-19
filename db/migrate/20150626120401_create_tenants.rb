class CreateTenants < ActiveRecord::Migration
  def up
    if Tenant.postgresql?
      old = Tenant.connection.schema_search_path
      Tenant.connection.schema_search_path = 'public'
    end

    unless table_exists? :tenants
      create_table :tenants do |t|
        t.string :domain
        t.string :from

        t.timestamps null: false
      end
    end

    if Tenant.postgresql?
      Tenant.connection.schema_search_path = old
    end
  end

  def down
    if Tenant.postgresql?
      old = Tenant.connection.schema_search_path
      Tenant.connection.schema_search_path = 'public'
    end

    if table_exists? :tenants
      drop_table :tenants
    end

    if Tenant.postgresql?
      Tenant.connection.schema_search_path = old
    end
  end
end
