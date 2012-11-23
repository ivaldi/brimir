class AddMessageIdToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :message_id, :string
    add_column :replies, :message_id, :string

    add_index :tickets, :message_id
    add_index :replies, :message_id
  end
end
