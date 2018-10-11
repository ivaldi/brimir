class AddJavascriptUrlToTenants < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :tenants, :javascript_url
      add_column :tenants, :javascript_url, :string
    end
  end
end
