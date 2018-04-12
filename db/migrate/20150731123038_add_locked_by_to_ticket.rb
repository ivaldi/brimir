class AddLockedByToTicket < ActiveRecord::Migration[4.2]
  def change
    add_column :tickets, :locked_by_id, :integer
    add_column :tickets, :locked_at, :datetime

    add_index :tickets, :locked_by_id
  end
end
