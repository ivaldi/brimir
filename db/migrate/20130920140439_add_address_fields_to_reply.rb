class AddAddressFieldsToReply < ActiveRecord::Migration
  def change
    add_column :replies, :to, :string
    add_column :replies, :cc, :string
    add_column :replies, :bcc, :string
  end
end
