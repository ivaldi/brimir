class AddUserToReply < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :user_id, :integer
    add_index :replies, :user_id
  end
end
