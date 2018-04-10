class AddAuthenticationTokenFieldToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :authentication_token, :string
  end
end
