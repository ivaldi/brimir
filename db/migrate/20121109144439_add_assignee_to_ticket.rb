class AddAssigneeToTicket < ActiveRecord::Migration
  def change
    add_column :tickets, :assignee_id, :integer

    add_index :tickets, :assignee_id
  end
end
