class AddNameToEmailAddress < ActiveRecord::Migration
  def change
    add_column :email_addresses, :name, :string
  end
end
