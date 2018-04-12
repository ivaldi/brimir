class RefactorFromInTickets < ActiveRecord::Migration[4.2]
  def up
    remove_column :tickets, :from
    add_column :tickets, :user_id, :integer

    add_index :tickets, :user_id
  end

  def down
  end
end
