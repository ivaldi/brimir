class AddSubAgentSupport < ActiveRecord::Migration[4.2]
  def change
    add_column :tickets, :to, :string, nil: true, default: nil
    add_column :users, :incoming_address, :string, nil: true, default: nil
    add_index :tickets, :to
  end
end
