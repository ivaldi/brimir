class AddNotesToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :notes, :text
  end
end
