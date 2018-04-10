class AddAddressFieldsToReply < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :to, :string
    add_column :replies, :cc, :string
    add_column :replies, :bcc, :string
  end
end
