class AddToEmailAddressToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :to_email_address_id, :integer

    add_index :tickets, :to_email_address_id
  end
end
