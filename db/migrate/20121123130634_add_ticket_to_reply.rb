class AddTicketToReply < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :ticket_id, :integer
    add_index :replies, :ticket_id
  end
end
