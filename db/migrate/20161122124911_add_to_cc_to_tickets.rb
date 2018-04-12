class AddToCcToTickets < ActiveRecord::Migration[4.2]
  def change
    add_column :tickets, :orig_to, :string
    add_column :tickets, :orig_cc, :string
  end
end
