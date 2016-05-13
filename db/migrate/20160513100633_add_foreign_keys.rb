class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :identities, :users
    add_foreign_key :labelings, :labels
    add_foreign_key :notifications, :users
    add_foreign_key :replies, :tickets
    add_foreign_key :replies, :users
    add_foreign_key :status_changes, :tickets

    add_foreign_key :tickets, :users, column: :assignee_id
    add_foreign_key :tickets, :users, column: :locked_by_id
    add_foreign_key :tickets, :email_addresses, column: :to_email_address_id
    add_foreign_key :tickets, :users
  end
end
