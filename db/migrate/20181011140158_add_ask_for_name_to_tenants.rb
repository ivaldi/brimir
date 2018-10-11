class AddAskForNameToTenants < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :tenants, :ask_for_name
      add_column :tenants, :ask_for_name, :boolean, default: false, nil: false
    end
  end
end
