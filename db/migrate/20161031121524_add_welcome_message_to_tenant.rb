class AddWelcomeMessageToTenant < ActiveRecord::Migration
  def change
    add_reference :tenants, :welcome_message, index: true
    add_foreign_key :tenants, :welcome_messages
  end
end
