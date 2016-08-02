class AddVerificationTokenToEmailAddress < ActiveRecord::Migration
  def change
    add_column :email_addresses, :verification_token, :string
  end
end
