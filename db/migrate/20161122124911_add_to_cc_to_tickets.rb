class AddToCcToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :orig_to, :string
    add_column :tickets, :orig_cc, :string
  end
end
