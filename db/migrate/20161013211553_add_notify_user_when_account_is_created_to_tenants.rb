class AddNotifyUserWhenAccountIsCreatedToTenants < ActiveRecord::Migration
  def change
    unless column_exists? :tenants, :notify_user_when_account_is_created
      add_column :tenants, :notify_user_when_account_is_created, :boolean, default: false
    end
  end
end
