class AddStylesheetToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :stylesheet_url, :string, default: Rails.application.config.tenant_default_stylesheet_url
  end
end
