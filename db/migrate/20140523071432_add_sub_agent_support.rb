class AddSubAgentSupport < ActiveRecord::Migration
  def change
    add_column :tickets, :to, :string, nil: true, default: nil
    add_column :users, :incoming_address, :string, nil: true, default: nil
    add_index :tickets, :to
  end
end
