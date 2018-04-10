class AddQuotePreferenceToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :include_quote_in_reply, :boolean, default: true, null: false
  end
end
