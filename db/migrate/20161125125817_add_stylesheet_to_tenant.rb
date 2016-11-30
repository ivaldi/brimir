class AddStylesheetToTenant < ActiveRecord::Migration
  def change
    unless column_exists? :tenants, :stylesheet_url
      add_column :tenants, :stylesheet_url, :string
    end
  end
end
