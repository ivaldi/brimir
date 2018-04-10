class AddRawMessageToTicketAndReply < ActiveRecord::Migration[4.2]
  def change
    add_attachment :tickets, :raw_message
    add_attachment :replies, :raw_message
  end
end
