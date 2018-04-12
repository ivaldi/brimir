class AddVerificationTokenToEmailAddress < ActiveRecord::Migration[4.2]
  def change
    add_column :email_addresses, :verification_token, :string
  end
end
