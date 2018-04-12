class CreateEmailAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :email_addresses do |t|
      t.string :email
      t.boolean :default, default: false, nil: false

      t.timestamps
    end
  end
end
