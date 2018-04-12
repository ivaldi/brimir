class AddShareDraftsToTenants < ActiveRecord::Migration[4.2]
  def change
    unless column_exists? :tenants, :share_drafts
      add_column :tenants, :share_drafts, :boolean, default: false, nil: false
    end
  end
end
