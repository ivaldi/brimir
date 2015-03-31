class AddPrivateMessages < ActiveRecord::Migration
  def change
    create_table :private_messages do |t|
      t.references :user
      t.references :ticket
      t.text :message
      t.timestamps
    end

    add_index :private_messages, :ticket_id
    add_index :private_messages, :user_id
  end
end
