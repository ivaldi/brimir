class AddRawMessageToTicketAndReply < ActiveRecord::Migration
  def change
    add_attachment :tickets, :raw_message
    add_attachment :replies, :raw_message
  end
end
