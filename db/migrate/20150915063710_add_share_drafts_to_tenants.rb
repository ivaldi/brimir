class AddShareDraftsToTenants < ActiveRecord::Migration
  def change
    unless column_exists? :tenants, :share_drafts
      add_column :tenants, :share_drafts, :boolean, default: false, nil: false
    end
  end
end
