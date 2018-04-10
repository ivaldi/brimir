class AddAssigneeToTicket < ActiveRecord::Migration[4.2]
  def change
    add_column :tickets, :assignee_id, :integer

    add_index :tickets, :assignee_id
  end
end
