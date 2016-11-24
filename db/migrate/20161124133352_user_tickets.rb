class UserTickets < ActiveRecord::Migration
  def change
    create_table :user_tickets, id: false do |t|
      t.integer :user_id, index: true
      t.integer :ticket_id, index: true
    end
  end
end
