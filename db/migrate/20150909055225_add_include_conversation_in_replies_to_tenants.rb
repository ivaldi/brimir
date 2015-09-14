class AddIncludeConversationInRepliesToTenants < ActiveRecord::Migration
  def change
    if Tenant.postgresql?
      old = Tenant.connection.schema_search_path
      Tenant.connection.schema_search_path = 'public'
    end

    unless column_exists? :tenants, :include_conversation_in_replies
      add_column :tenants, :include_conversation_in_replies, :boolean, default: false, null: false
      add_column :tenants, :logo_url, :string
      add_column :tenants, :reply_email_footer, :text
    end

    if Tenant.postgresql?
      Tenant.connection.schema_search_path = old
    end
  end
end
