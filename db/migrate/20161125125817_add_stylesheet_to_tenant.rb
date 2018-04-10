class AddStylesheetToTenant < ActiveRecord::Migration[4.2]
  def change
    unless column_exists? :tenants, :stylesheet_url
      add_column :tenants, :stylesheet_url, :string
    end
  end
end
