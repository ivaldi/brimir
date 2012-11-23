class AddTicketToReply < ActiveRecord::Migration
  def change
    add_column :replies, :ticket_id, :integer
    add_index :replies, :ticket_id
  end
end
