class AddNameToEmailAddress < ActiveRecord::Migration[4.2]
  def change
    add_column :email_addresses, :name, :string
  end
end
